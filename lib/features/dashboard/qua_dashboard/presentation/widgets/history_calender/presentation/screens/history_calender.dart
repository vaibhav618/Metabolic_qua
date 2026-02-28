import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_calender.dart';

class HistoryCalender extends StatefulWidget {
  const HistoryCalender({super.key});

  @override
  State<HistoryCalender> createState() => _HistoryCalenderState();
}

class _HistoryCalenderState extends State<HistoryCalender> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {

    final Map<DateTime, double> scoreAvailable = {
      DateTime(2025, 12, 10): 68,
      DateTime(2025, 12, 12): 78,
    };

    final Map<DateTime, String> weightByDate = {
      DateTime(2025, 12, 10): "73kg",
      DateTime(2025, 12, 12): "72kg",
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        title: Text(
          "Score Calendar",
          style: GoogleFonts.poppins(fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: CustomCalendar(
            initialMonth: DateTime.now(),
            selectedDate: _selected,
            scoreAvailable: scoreAvailable,
            weightByDate: weightByDate,
            onDateSelected: (date) {
              setState(() => _selected = date);
            },
          ),
        ),
      ),
    );
  }
}
