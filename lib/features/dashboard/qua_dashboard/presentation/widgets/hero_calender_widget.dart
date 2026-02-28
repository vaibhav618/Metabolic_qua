import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HeroCalenderWidget extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<DateTime> dateList;

  const HeroCalenderWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.dateList,
  });

  @override
  State<HeroCalenderWidget> createState() => _HeroCalenderWidgetState();
}

class _HeroCalenderWidgetState extends State<HeroCalenderWidget> {
  final ScrollController _scrollController = ScrollController();
  late List<DateTime> _dateList;

  @override
  void initState() {
    super.initState();
    _dateList = _generateDateList(widget.dateList, widget.selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveItem();
    });
  }

  List<DateTime> _generateDateList(List<DateTime> dateList, DateTime selectedDate) {
    // 1. If dateList is empty, start from Jan 1, 2025 until today
    if (dateList.isEmpty) {
      DateTime startDate = DateTime(2025, 12, 11);
      DateTime today = DateTime.now().add(const Duration(days: 4));
      List<DateTime> generated = [];

      DateTime current = startDate;
      // Fill list from Jan 1, 2025 to Today
      while (!current.isAfter(today)) {
        generated.add(current);
        current = current.add(const Duration(days: 1));
      }

      // Ensure at least 7 dates exist for UI consistency even if today is early Jan
      if (generated.length < 7) {
        DateTime fillDate = generated.last.add(const Duration(days: 1));
        while (generated.length < 7) {
          generated.add(fillDate);
          fillDate = fillDate.add(const Duration(days: 1));
        }
      }
      return generated;
    }

    // 2. Logic if dateList is NOT empty (Original logic for centering 7 dates)
    int missingDatesCount = 7 - dateList.length;
    if (missingDatesCount > 0) {
      DateTime startDate = selectedDate.subtract(Duration(days: missingDatesCount ~/ 2));
      List<DateTime> filledDates = [];
      for (int i = 0; i < 7; i++) {
        filledDates.add(startDate.add(Duration(days: i)));
      }
      return filledDates;
    } else {
      return dateList;
    }
  }

  void _scrollToActiveItem() {
    int activeIndex = _dateList.indexWhere((date) =>
        DateUtils.isSameDay(date, widget.selectedDate));

    if (activeIndex != -1) {
      _scrollToIndex(activeIndex);
    }
  }

  void _scrollToIndex(int index) {
    const double itemWidth = 36;
    const double gap = 10;

    if (_scrollController.hasClients) {
      final double viewportWidth = _scrollController.position.viewportDimension;
      final double itemCenter = index * (itemWidth + gap) + (itemWidth / 2);
      double targetOffset = itemCenter - viewportWidth / 2;

      final maxExtent = _scrollController.position.maxScrollExtent;
      targetOffset = targetOffset.clamp(0, maxExtent);

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    return SizedBox(
      height: 50,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dateList.length,
        itemBuilder: (context, index) {
          DateTime date = _dateList[index];
          String day = DateFormat('dd').format(date);
          String dayName = DateFormat('EEE').format(date);

          bool isSelected = DateUtils.isSameDay(date, widget.selectedDate);
          bool isFutureDate = date.isAfter(today) && !DateUtils.isSameDay(date, today);

          return GestureDetector(
            onTap: isFutureDate
                ? null
                : () {
              widget.onDateSelected(date);
              _scrollToIndex(index);
            },
            child: Container(
              width: 36,
              padding: const EdgeInsets.all(5),
              decoration: ShapeDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.30)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: GoogleFonts.poppins(
                      color: isFutureDate ? Colors.white.withOpacity(0.5) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    dayName,
                    style: GoogleFonts.poppins(
                      color: isFutureDate ? Colors.white.withOpacity(0.8) : Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
      ),
    );
  }
}