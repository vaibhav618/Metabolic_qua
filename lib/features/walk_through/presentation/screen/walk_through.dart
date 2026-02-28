import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:respyr_dietitian/routes/app_routes.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';

import '../../bloc/walkthrough_bloc.dart';
import '../../bloc/walkthrough_event.dart';
import '../../bloc/walkthrough_state.dart';
import '../../data/walk_through_content.dart';
import '../widgets/walk_through_bottom_nav.dart';
import '../widgets/walk_through_progress_indicator.dart';

class WalkthroughScreen extends StatelessWidget {
  const WalkthroughScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalkthroughBloc(),
      child: const _WalkthroughBody(),
    );
  }
}

class _WalkthroughBody extends StatefulWidget {
  const _WalkthroughBody();

  @override
  State<_WalkthroughBody> createState() => _WalkthroughBodyState();
}

class _WalkthroughBodyState extends State<_WalkthroughBody> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleStateChange(
      BuildContext context, WalkthroughState state) async {
    if (state.isCompleted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_walkthrough', true);
      if (!mounted) return;
      context.go(AppRoutes.signInOptions);
      return;
    }

    if (_pageController.hasClients) {
      final currentPage = _pageController.page?.round() ?? 0;
      if (currentPage != state.currentPage) {
        _pageController.animateToPage(
          state.currentPage,
          duration: Duration(
            milliseconds: rh(context: context, px: 450).round(),
          ),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = walkThroughContent.length;

    return BlocConsumer<WalkthroughBloc, WalkthroughState>(
      listenWhen: (prev, curr) =>
      prev.isCompleted != curr.isCompleted ||
          prev.currentPage != curr.currentPage,
      listener: _handleStateChange,
      buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
      builder: (context, state) {
        final bloc = context.read<WalkthroughBloc>();

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: rh(context: context, px: 18),
              ),
              child: Column(
                children: [
                  buildWalkThoughProgressIndicator(state.currentPage),
                  Align(
                    alignment: Alignment.centerRight,
                    child: state.currentPage < totalPages - 1
                        ? SizedBox(
                      height: rh(context: context, px: 60),
                      child: TextButton(
                        onPressed: () =>
                            bloc.add(const SkipPressed()),
                        child: Text(
                          "Skip",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF308BF9),
                            fontSize:
                            rh(context: context, px: 15),
                            fontWeight: FontWeight.w600,
                            letterSpacing:
                            rh(context: context, px: 0.30),
                          ),
                        ),
                      ),
                    )
                        : SizedBox(
                      height: rh(context: context, px: 60),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      children: walkThroughContent,
                    ),
                  ),
                  WalkThroughBottomNav(
                    bloc: bloc,
                    currentPage: state.currentPage,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
