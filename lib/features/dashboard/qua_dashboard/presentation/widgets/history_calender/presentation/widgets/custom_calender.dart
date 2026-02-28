import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime? initialMonth;
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? selectedDate;

  final Map<DateTime, Color>? dayBackgroundColors;

  // ✅ NEW (as requested)
  final Map<DateTime, double>? scoreAvailable;
  final Map<DateTime, String>? weightByDate;

  final int monthsToShow;

  const CustomCalendar({
    super.key,
    this.initialMonth,
    this.onDateSelected,
    this.selectedDate,
    this.dayBackgroundColors,
    this.scoreAvailable,
    this.weightByDate,
    this.monthsToShow = 12,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  int _daysInMonth(DateTime date) {
    final nextMonth =
    date.month < 12 ? DateTime(date.year, date.month + 1, 1) : DateTime(date.year + 1, 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  @override
  Widget build(BuildContext context) {
    final baseMonth = DateTime(
      widget.initialMonth?.year ?? DateTime.now().year,
      widget.initialMonth?.month ?? DateTime.now().month,
    );

    final months = List.generate(
      widget.monthsToShow,
          (i) => DateTime(baseMonth.year, baseMonth.month - i, 1),
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: months.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildMonthView(context, months[index]),
        );
      },
    );
  }

  Widget _buildMonthView(BuildContext context, DateTime month) {
    final daysInMonth = _daysInMonth(month);
    final firstDay = DateTime(month.year, month.month, 1).weekday;

    final List<Widget> dayTiles = [];

    for (int i = 1; i < firstDay; i++) {
      dayTiles.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final key = _normalize(date);

      final hasScore = widget.scoreAvailable?[key];
      final weight = widget.weightByDate?[key];

      dayTiles.add(
        GestureDetector(
          onTap: () {
            setState(() => _selectedDate = date);
            widget.onDateSelected?.call(date);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "$day",
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF252525),
                  height: 1.0
                ),
              ),

              if (hasScore != null) ...[
                const SizedBox(height: 2),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFDA5747),
                    shape: OvalBorder(),
                  ),
                ),
              ],

              if (weight != null) ...[
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    weight,
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF252525),
                      height: 1.0
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    const weekdayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_monthName(month.month)} ${month.year}",
          style: GoogleFonts.poppins(
            fontSize: 34,
            fontWeight: FontWeight.w400,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "12 Tests Recorded",
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                children: weekdayLabels
                    .map(
                      (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: GoogleFonts.poppins(fontSize: 10),
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: dayTiles,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return months[m - 1];
  }
}
