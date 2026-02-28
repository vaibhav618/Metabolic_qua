import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:respyr_dietitian/core/utils/text_style.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/data/model/dietitian_dashboard_meal_model.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_cubit.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_state.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/widgets/customized_dashboard_color_text.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/widgets/dietitian_dashboard_result.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/widgets/food_container_list.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class DietitianDashboardScreen extends StatelessWidget {
  const DietitianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DietitianDashboardCubit>().loadDietitianDashboard(
      DateTime.now(),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocBuilder<DietitianDashboardCubit, DietitianDashboardState>(
        builder: (context, state) {
          if (state is DietitianDashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF308BF9)),
            );
          } else if (state is DietitianDashboardLoaded) {
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor:
                    CustomizedDashboardColorText.getGradientColor()
                        .colors
                        .first,
                statusBarIconBrightness: Brightness.dark,
              ),
            );
            return _DashboardMealView(meal: state.meal);
          } else if (state is DietitianDashboardError) {
            return const Center(child: Text("Error loading dashboard"));
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _DashboardMealView extends StatefulWidget {
  final DietitianDashboardMealModel meal;
  const _DashboardMealView({required this.meal});

  @override
  State<_DashboardMealView> createState() => _DashboardMealViewState();
}

class _DashboardMealViewState extends State<_DashboardMealView> {
  late LinearGradient _currentGradient;
  late Color _iconTextColor;
  late Color _totalContainerColor;
  late Color _titleColor;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateColors();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkTimeChange(),
    );
  }

  void _updateColors() {
    _currentGradient = CustomizedDashboardColorText.getGradientColor();
    _iconTextColor = CustomizedDashboardColorText.dashboardIconTextColor();
    _totalContainerColor = CustomizedDashboardColorText.totalContColor();
    _titleColor = CustomizedDashboardColorText.titleColor();
  }

  void _checkTimeChange() {
    final newGradient = CustomizedDashboardColorText.getGradientColor();
    final newTextColor = CustomizedDashboardColorText.dashboardIconTextColor();
    final newTotalContColor = CustomizedDashboardColorText.totalContColor();
    final newTitleColor = CustomizedDashboardColorText.titleColor();

    if (newGradient.colors.first != _currentGradient.colors.first) {
      setState(() {
        _currentGradient = newGradient;
        _iconTextColor = newTextColor;
        _totalContainerColor = newTotalContColor;
        _titleColor = newTitleColor;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(gradient: _currentGradient),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _dashboardDietitianHeader(),
                  const SizedBox(height: 40),

                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 800),
                    style: poppinsTextStyle(
                      color: _iconTextColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text(
                      "It's ${CustomizedDashboardColorText.mealTitle()} time!",
                    ),
                  ),

                  const SizedBox(height: 10),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 800),
                    style: poppinsTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: _iconTextColor,
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: poppinsTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: _iconTextColor,
                        ),
                        children: [
                          const TextSpan(text: 'As per your '),
                          TextSpan(
                            text: 'diet plan',
                            style: poppinsTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _iconTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      CustomizedDashboardColorText.mealTime(),
                      textAlign: TextAlign.center,
                      style: poppinsTextStyle(
                        color: _iconTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  FoodContainerList(
                    foodItems: widget.meal.foodItems,
                    iconColor: _iconTextColor,
                  ),

                  _totalFoodCountContainer(context, widget.meal),

                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap:
                        () => context
                            .read<DietitianDashboardCubit>()
                            .checkDeviceAbortStatus(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Take Test",
                          style: poppinsTextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                DietitianDashboardResult(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardDietitianHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 800),
              style: poppinsTextStyle(
                color: _titleColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              child: const Text('Hi Sparsh'),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 800),
              style: poppinsTextStyle(
                color: _titleColor,
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
              child: Text(CustomizedDashboardColorText.greetingText()),
            ),
          ],
        ),
        Row(
          children: [
            _circleIcon("assets/images/dietitian_dashboard/messages_icon.svg"),
            const SizedBox(width: 8),
            _circleIcon("assets/images/common/profile_logo.svg"),
          ],
        ),
      ],
    );
  }

  Widget _circleIcon(String assetPath) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      height: 40,
      width: 40,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: _iconTextColor, shape: BoxShape.circle),
      child: SvgPicture.asset(
        assetPath,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }

  Widget _totalFoodCountContainer(
    BuildContext context,
    DietitianDashboardMealModel meal,
  ) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _totalContainerColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: poppinsTextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    const TextSpan(text: 'Your Meal Macros goal\n'),
                    TextSpan(
                      text: ' 3 items',
                      style: poppinsTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${meal.totalCalories} kcal\nCalories',
                textAlign: TextAlign.right,
                style: poppinsTextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white54),
          Row(
            children: [
              Expanded(
                child: _textRowButton(
                  "assets/images/common/doc_svg.svg",
                  "View full plan",
                  () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _textRowButton(
                  "assets/images/common/rice_bowl.svg",
                  "Log this meal",
                  () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textRowButton(String svgAsset, String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (svgAsset.isNotEmpty)
            SvgPicture.asset(
              svgAsset,
              height: 16,
              width: 16,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          const SizedBox(width: 5),
          Text(
            text,
            style: poppinsTextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.keyboard_arrow_right, color: Colors.white),
        ],
      ),
    );
  }
}
