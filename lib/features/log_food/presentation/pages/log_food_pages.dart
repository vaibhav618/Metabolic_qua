import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:respyr_dietitian/features/log_food/domain/entities/food_item.dart';
import 'package:respyr_dietitian/features/log_food/domain/entities/meal_category.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/log_food_cubit.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/log_food_state.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/test_timer_cubit/test_timer_cubit.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/test_timer_cubit/test_timer_state.dart';
import 'package:respyr_dietitian/features/log_food/presentation/widgets/log_food_item_list.dart';
import 'package:respyr_dietitian/features/log_food/presentation/widgets/nutrients_progess.dart';

class LogFoodPage extends StatelessWidget {
  /// Optional map you can pass from DietPlanScreen:
  /// { MealCategory.breakfast: "08:00–09:00 AM", ... }
  final Map<MealCategory, String>? categoryTitles;

  const LogFoodPage({super.key, this.categoryTitles});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Also allow arguments via Navigator if you prefer:
    final navArgs = ModalRoute.of(context)?.settings.arguments;
    final Map<MealCategory, String>? incoming =
    (navArgs is Map<MealCategory, String>) ? navArgs : null;

    // Priority: constructor > navigator args
    final Map<MealCategory, String> titles =
        categoryTitles ?? incoming ?? const {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: BlocBuilder<LogFoodCubit, LogFoodState>(
          builder: (context, state) {
            if (state.selectedCategory == null) {
              context.read<LogFoodCubit>().openCategory(MealCategory.wakeUp);
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_sharp),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log food',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                '07 July',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  height: 1.10,
                                  letterSpacing: -0.20,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              context.read<TestTimerCubit>().startTest();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                isDismissible: true,
                                builder: (_) => const TestBottomSheet(),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF308BF9),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                'Save',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1.10,
                                  letterSpacing: 0.30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // -------- LEFT (Categories) + RIGHT (Food list) --------
                      Expanded(
                        child: Row(
                          children: [
                            // LEFT: categories (dynamic; shows actual time/dietTitle)
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                  ),
                                ),
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  children: _buildDynamicCategories(context, titles),
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),

                            // RIGHT: items for selected category
                            Expanded(
                              flex: 3,
                              child: _buildFoodList(context, state),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // -------- Bottom sheet blur + sheet --------
                if (state.isBottomSheetOpen)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => context.read<LogFoodCubit>().closeBottomSheet(),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          color: Colors.grey.shade400.withAlpha(174),
                        ),
                      ),
                    ),
                  ),
                if (state.isBottomSheetOpen)
                  DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    minChildSize: 0.6,
                    maxChildSize: 0.6,
                    builder: (_, controller) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: ListView(
                            controller: controller,
                            padding: const EdgeInsets.all(20),
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(
                                          value: 0.75,
                                          strokeWidth: 6,
                                          backgroundColor: Colors.grey.shade200,
                                          color: Colors.orange,
                                        ),
                                        Center(
                                          child: SvgPicture.asset(
                                            "assets/images/common/calories.svg",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Calories',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF535359),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          height: 1.10,
                                          letterSpacing: -0.24,
                                        ),
                                      ),
                                      Text(
                                        '1200 kcal',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF252525),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          height: 1.26,
                                          letterSpacing: -0.40,
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF252525),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.20,
                                          ),
                                          children: [
                                            const TextSpan(text: 'out of '),
                                            TextSpan(
                                              text: '1800kcal',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: const [
                                  Expanded(
                                    child: NutrientsProgessWidget(
                                      name: "Protein",
                                      value: "70g",
                                      total: "100g",
                                      color: Color(0xFFFFC412),
                                      progress: 0.70,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: NutrientsProgessWidget(
                                      name: "Protein",
                                      value: "30g",
                                      total: "100g",
                                      color: Color(0xFF38A250),
                                      progress: 0.30,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: const [
                                  Expanded(
                                    child: NutrientsProgessWidget(
                                      name: "Protein",
                                      value: "80g",
                                      total: "100g",
                                      color: Color(0xFF38A250),
                                      progress: 0.80,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: NutrientsProgessWidget(
                                      name: "Protein",
                                      value: "21g",
                                      total: "100g",
                                      color: Color(0xFFFFC412),
                                      progress: 0.21,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: _bottomNavigation(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // -------------------- LEFT PANE: dynamic categories --------------------

  List<Widget> _buildDynamicCategories(
      BuildContext context,
      Map<MealCategory, String> categoryTitles,
      ) {
    final cubit = context.read<LogFoodCubit>();
    final allItems = cubit.state.items;

    // Group items by category (only categories that actually have items)
    final Map<MealCategory, List<FoodItem>> grouped = {};
    for (final item in allItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    // Keep a consistent visual order
    const ordered = [
      MealCategory.wakeUp,
      MealCategory.breakfast,
      MealCategory.lunch,
      MealCategory.snacks,
      MealCategory.dinner,
      MealCategory.sleep,
    ];

    final widgets = <Widget>[];
    for (final category in ordered) {
      final items = grouped[category];
      if (items == null || items.isEmpty) continue;

      final title = _categoryDisplayName(category);
      // Show the actual dietTitle/time if provided for this category
      final timeText = categoryTitles[category] ?? '—';

      widgets.addAll([
        _buildCategoryCard(context, category, title, timeText),
        const Divider(),
      ]);
    }

    return widgets;
  }

  String _categoryDisplayName(MealCategory c) {
    switch (c) {
      case MealCategory.wakeUp:
        return "Wake Up";
      case MealCategory.breakfast:
        return "Breakfast";
      case MealCategory.lunch:
        return "Lunch";
      case MealCategory.snacks:
        return "Snacks";
      case MealCategory.dinner:
        return "Dinner";
      case MealCategory.sleep:
        return "Sleep";
    }
  }

  // -------------------- RIGHT PANE: items list --------------------

  Widget _bottomNavigation(BuildContext context, LogFoodState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 4,
                  backgroundColor: Colors.white24,
                  color: Colors.greenAccent,
                ),
                const Center(
                  child: Icon(Icons.emoji_events, color: Colors.white),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Daily Goal',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '75% completed',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              context.read<LogFoodCubit>().toggleBottomSheet();
            },
            icon: Icon(
              state.isBottomSheetOpen ? Icons.close : Icons.keyboard_arrow_up,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(BuildContext context, LogFoodState state) {
    final scrollController = ScrollController();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topRight: Radius.circular(15)),
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        radius: const Radius.circular(10),
        thickness: 2,
        child: Column(
          children: [
            _buildSelectAllRow(
              context,
              context.read<LogFoodCubit>().itemsForSelectedCategory,
              state.selectedCategory!,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: context
                    .read<LogFoodCubit>()
                    .itemsForSelectedCategory
                    .length,
                itemBuilder: (context, index) {
                  final item = context
                      .read<LogFoodCubit>()
                      .itemsForSelectedCategory[index];
                  return Column(
                    children: [
                      LogFoodItemList(
                        item: item,
                        onTap: () {
                          final realIndex = context
                              .read<LogFoodCubit>()
                              .state
                              .items
                              .indexOf(item);
                          context.read<LogFoodCubit>().toggleItem(realIndex);
                        },
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectAllRow(
      BuildContext context,
      List<FoodItem> items,
      MealCategory category,
      ) {
    final allSelected = items.every((item) => item.isSelected);
    return Row(
      children: [
        Checkbox(
          checkColor: const Color(0xFF308BF9),
          activeColor: Colors.white,
          side: WidgetStateBorderSide.resolveWith(
                (states) => const BorderSide(color: Color(0xFFA1A1A1), width: 2),
          ),
          value: allSelected,
          onChanged: (_) {
            context.read<LogFoodCubit>().toggleSelectAll(
              category,
              !allSelected,
            );
          },
        ),
        Text(
          'Select all',
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
      BuildContext context,
      MealCategory category,
      String title,
      String time,
      ) {
    final cubit = context.watch<LogFoodCubit>();
    final selected = cubit.selectedCount(category);
    final total = cubit.totalCount(category);

    String statusText;
    Color statusColor;
    Color statusTextColor;

    if (selected == 0) {
      statusText = "Pending";
      statusColor = const Color(0xFFFFEFED);
      statusTextColor = const Color(0xFFDA5747);
    } else if (selected < total) {
      statusText = "$selected/$total Selected";
      statusColor = const Color(0xFFF0F0F0);
      statusTextColor = const Color(0xFF595959);
    } else {
      statusText = "$selected/$total Selected";
      statusColor = const Color(0xFFEBFFF0);
      statusTextColor = const Color(0xFF3FAF58);
    }

    return GestureDetector(
      onTap: () => context.read<LogFoodCubit>().openCategory(category),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                        letterSpacing: -0.48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: statusColor,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 60,
                    maxWidth: 100,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        color: statusTextColor,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Gray small time/dietTitle line (unchanged UI)
            Text(
              time,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TestBottomSheet extends StatelessWidget {
  const TestBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TestTimerCubit, TestTimerState>(
      builder: (context, state) {
        if (state is TestTimerInProgress) {
          final hours =
          state.remainingTime.inHours.remainder(60).toString().padLeft(2, '0');
          final days =
          state.remainingTime.inDays.remainder(60).toString().padLeft(2, '0');
          final minutes = state.remainingTime.inMinutes
              .remainder(60)
              .toString()
              .padLeft(2, '0');
          final seconds = state.remainingTime.inSeconds
              .remainder(60)
              .toString()
              .padLeft(2, '0');

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Countdown Box
                Container(
                  height: 124,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFFF0F0F0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your test timing ends in',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.24,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('days'),
                            _buildLabel('hrs'),
                            _buildLabel('mins'),
                            _buildLabel('secs'),
                          ],
                        ),
                      ),
                      // Timer Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTime(days),
                          _buildColon(),
                          _buildTime(hours),
                          _buildColon(),
                          _buildTime(minutes),
                          _buildColon(),
                          _buildTime(seconds),
                        ],
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset("assets/images/common/test_not_taken.svg"),
                const SizedBox(height: 16),
                Text(
                  "You Haven't Tested Yet Today",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Take test before your dietician find out!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your dietician uses these results to understand your daily progress and provide the right guidance.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => context.read<TestTimerCubit>().completeTest(),
                  child: const Text("Slide to start test"),
                ),
              ],
            ),
          );
        } else if (state is TestTimerExpired) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Center(child: Text("⏰ Test Expired")),
          );
        } else if (state is TestTimerCompleted) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Center(child: Text("✅ Test Completed")),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Reusable helpers
  Widget _buildLabel(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: const Color(0xFF252525),
        fontSize: 8,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.16,
      ),
    );
  }

  Widget _buildTime(String value) {
    return Text(
      value,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: const Color(0xFF252525),
        fontSize: 25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.50,
      ),
    );
  }

  Widget _buildColon() {
    return Text(
      ':',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: const Color(0xFF252525),
        fontSize: 25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.50,
      ),
    );
  }
}
