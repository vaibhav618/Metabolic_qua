import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../core/size/get_height.dart';
import '../../../../routes/app_routes.dart';
import '../../../bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';
import '../../domain/dietitian_result_view_model.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_cubit.dart';

import '../cubit/dietitian_result_state.dart';
import '../widgets/result_overview_screen.dart';
import '../widgets/sliver_tabbar_delegate.dart';
import '../widgets/tab_widget.dart';
import '../widgets/section_widget_2.dart';

class DetailedResultScreen extends StatefulWidget {
  final TestResultResponse testResultResponse;
  final ClientProfileModel clientProfileModel;

  const DetailedResultScreen({
    super.key,
    required this.testResultResponse,
    required this.clientProfileModel,
  });

  @override
  State<DetailedResultScreen> createState() => _DetailedResultScreenState();
}

class _DetailedResultScreenState extends State<DetailedResultScreen>
    with WidgetsBindingObserver {
  final viewModel = DietitianResultViewModel();

  Timer? _scrollDebounce;

  final GlobalKey _tabsBarKey = GlobalKey();
  double _tabsBarHeight = 0;

  double? _fatReveal;
  double? _gutReveal;
  double? _liverReveal;

  bool _offsetsComputed = false;
  bool _computeScheduled = false;

  bool _programmaticScroll = false;

  static const Duration _tabAnimDuration = Duration(milliseconds: 420);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    viewModel.scrollController.addListener(_onVerticalScroll);
    _scheduleComputeOffsets();
  }

  @override
  void didChangeMetrics() {
    _offsetsComputed = false;
    _scheduleComputeOffsets();
    super.didChangeMetrics();
  }

  void _onVerticalScroll() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      if (_programmaticScroll) return;
      _handleScrollPosition();
    });
  }

  void _scheduleComputeOffsets() {
    if (_computeScheduled) return;
    _computeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _computeScheduled = false;
      _computeOffsetsIfPossible();
    });
  }

  void _computeOffsetsIfPossible() {
    if (!mounted) return;

    final tabsCtx = _tabsBarKey.currentContext;
    if (tabsCtx != null) {
      final box = tabsCtx.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        _tabsBarHeight = box.size.height;
        viewModel.setPinnedHeaderHeight(_tabsBarHeight);
      }
    }

    final fat = _revealOffsetForKey(viewModel.fatAnchorKey);
    final gut = _revealOffsetForKey(viewModel.gutAnchorKey);
    final liver = _revealOffsetForKey(viewModel.liverAnchorKey);

    if (fat == null || gut == null || liver == null) {
      _scheduleComputeOffsets();
      return;
    }

    _fatReveal = fat;
    _gutReveal = gut;
    _liverReveal = liver;
    _offsetsComputed = true;
  }

  double? _revealOffsetForKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;

    final renderObject = ctx.findRenderObject();
    if (renderObject == null) return null;

    final viewport = RenderAbstractViewport.of(renderObject);
    final reveal = viewport.getOffsetToReveal(renderObject, 0.0);
    return reveal.offset;
  }

  void _handleScrollPosition() {
    if (!viewModel.scrollController.hasClients) return;

    if (!_offsetsComputed) {
      _scheduleComputeOffsets();
      return;
    }
    if (_fatReveal == null || _gutReveal == null || _liverReveal == null) return;

    final cubit = context.read<DietitianResultCubit>();
    final offset = viewModel.scrollController.offset;

    final tabsH = (_tabsBarHeight > 0) ? _tabsBarHeight : rh(context: context, px: 52);

    final adjusted = offset + tabsH + rh(context: context, px: 12);

    String? nextTab;
    GlobalKey? nextTabKey;

    if (adjusted >= _fatReveal! && adjusted < _gutReveal!) {
      nextTab = "Fat";
      nextTabKey = viewModel.tabFatKey;
    } else if (adjusted >= _gutReveal! && adjusted < _liverReveal!) {
      nextTab = "Gut";
      nextTabKey = viewModel.tabGutKey;
    } else if (adjusted >= _liverReveal!) {
      nextTab = "Liver";
      nextTabKey = viewModel.tabLiverKey;
    }

    if (nextTab != null && cubit.state.selectedTab != nextTab) {
      cubit.changeTab(nextTab);
      if (nextTabKey != null) viewModel.tabScrollTo(nextTabKey);
    }
  }

  Future<void> _ensureSectionIsLaidOut(GlobalKey sectionAnchorKey) async {
    if (!viewModel.scrollController.hasClients) return;

    for (int i = 0; i < 3; i++) {
      final off = _revealOffsetForKey(sectionAnchorKey);
      if (off != null) return;

      final current = viewModel.scrollController.offset;
      final jump = viewModel.scrollController.position.viewportDimension * 0.9;

      _programmaticScroll = true;
      try {
        await viewModel.scrollController.animateTo(
          min(current + jump, viewModel.scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
        );
      } finally {
        _programmaticScroll = false;
      }

      await Future.delayed(const Duration(milliseconds: 16));
      _computeOffsetsIfPossible();
    }
  }

  Future<void> _scrollToSection(
      GlobalKey sectionAnchorKey,
      String tabName,
      GlobalKey tabKey,
      ) async {
    if (!mounted) return;

    final cubit = context.read<DietitianResultCubit>();
    cubit.changeTab(tabName);
    viewModel.tabScrollTo(tabKey);

    _offsetsComputed = false;
    _scheduleComputeOffsets();
    await Future.delayed(const Duration(milliseconds: 16));
    _computeOffsetsIfPossible();

    await _ensureSectionIsLaidOut(sectionAnchorKey);

    final targetReveal = _revealOffsetForKey(sectionAnchorKey);
    if (targetReveal == null) return;

    final tabsH = (_tabsBarHeight > 0) ? _tabsBarHeight : rh(context: context, px: 52);

    final target = max(0.0, targetReveal - tabsH - rh(context: context, px: 12));

    _programmaticScroll = true;
    try {
      await viewModel.scrollController.animateTo(
        target,
        duration: _tabAnimDuration,
        curve: Curves.easeInOut,
      );
    } finally {
      _programmaticScroll = false;
    }

    _offsetsComputed = false;
    _scheduleComputeOffsets();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollDebounce?.cancel();
    viewModel.scrollController.removeListener(_onVerticalScroll);
    viewModel.dispose();
    super.dispose();
  }

  Future<bool> navToDashboard(BuildContext context) async {
    if (context.mounted) {
      context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
    }
    return false;
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(dateTime);
      final local = dt.toLocal();
      return DateFormat('d MMM yyyy, h:mma').format(local);
    } catch (_) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cache = MediaQuery.of(context).size.height * 6;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF308BF9),
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.clientProfileModel.profileName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: rh(context: context, px: 18),
                fontWeight: FontWeight.w600,
                height: 1.1,
                letterSpacing: rh(context: context, px: -0.72),
              ),
            ),
            Text(
              formatDateTime(widget.testResultResponse.dateTime),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: rh(context: context, px: 10),
                fontWeight: FontWeight.w400,
                height: 1.1,
                letterSpacing: rh(context: context, px: -0.2),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => navToDashboard(context),
            icon: const Icon(Icons.close, color: Colors.white),
          )
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<DietitianResultCubit, DietitianResultState>(
          builder: (context, state) {
            _scheduleComputeOffsets();

            return CustomScrollView(
              controller: viewModel.scrollController,
              cacheExtent: cache,
              slivers: [
                ResultOverViewScreen(
                  state: state,
                  clientProfileModel: widget.clientProfileModel,
                  result: widget.testResultResponse,
                ),
                _buildStickyTabs(context, state),
                _buildSections(context, state),
                _buildDisclaimer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStickyTabs(BuildContext context, DietitianResultState state) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverTabBarDelegate(
        child: Container(
          key: _tabsBarKey,
          child: SingleChildScrollView(
            controller: viewModel.tabScrollController,
            scrollDirection: Axis.horizontal,
            child: _buildTabs(state),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(DietitianResultState state) {
    return Row(
      children: [
        TabWidget(
          key: viewModel.tabFatKey,
          text: "Fuel & Energy Trends",
          isActive: state.selectedTab == "Fat",
          onTap: () => _scrollToSection(
            viewModel.fatAnchorKey,
            "Fat",
            viewModel.tabFatKey,
          ),
        ),
        _divider(),
        TabWidget(
          key: viewModel.tabGutKey,
          text: "Digestive Balance Trends",
          isActive: state.selectedTab == "Gut",
          onTap: () => _scrollToSection(
            viewModel.gutAnchorKey,
            "Gut",
            viewModel.tabGutKey,
          ),
        ),
        _divider(),
        TabWidget(
          key: viewModel.tabLiverKey,
          text: "Metabolic Recovery Trends",
          isActive: state.selectedTab == "Liver",
          onTap: () => _scrollToSection(
            viewModel.liverAnchorKey,
            "Liver",
            viewModel.tabLiverKey,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
    height: rh(context: context, px: 43),
    width: rh(context: context, px: 1),
    color: Colors.black,
  );

  Widget _buildSections(BuildContext context, DietitianResultState state) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: EdgeInsets.all(rh(context: context, px: 16)),
          child: KeyedSubtree(
            key: viewModel.fatAnchorKey,
            child: SectionWidgetNew(
              metabolismType: 'Fat',
              state: state,
              clientProfileModel: widget.clientProfileModel,
              result: widget.testResultResponse,
              context: context,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(rh(context: context, px: 16)),
          child: KeyedSubtree(
            key: viewModel.gutAnchorKey,
            child: SectionWidgetNew(
              metabolismType: 'Gut',
              state: state,
              clientProfileModel: widget.clientProfileModel,
              result: widget.testResultResponse,
              context: context,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(rh(context: context, px: 16)),
          child: KeyedSubtree(
            key: viewModel.liverAnchorKey,
            child: SectionWidgetNew(
              metabolismType: 'Liver',
              state: state,
              clientProfileModel: widget.clientProfileModel,
              result: widget.testResultResponse,
              context: context,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildDisclaimer() {
    return SliverToBoxAdapter(
      child: SafeArea(
        minimum: EdgeInsets.only(bottom: rh(context: context, px: 26)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Disclaimer',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  letterSpacing: rh(context: context, px: -0.24),
                ),
              ),
              SizedBox(height: rh(context: context, px: 10)),
              Text(
                "Important Safety and Wellness Disclaimer\nRespyr and its associated device are intended for general wellness and lifestyle awareness purposes only.\nRespyr is designed for use by healthy individuals and is not intended for medical diagnosis, treatment, cure, prevention, or clinical use.\nRespyr does not provide medical advice. Always consult a qualified healthcare professional before making medical decisions or changes to your health routine.",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  letterSpacing: rh(context: context, px: -0.24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
