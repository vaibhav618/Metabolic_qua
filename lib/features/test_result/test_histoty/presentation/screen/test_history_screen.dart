import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../data/modal/score_point.dart';
import '../../data/week_range.dart';
import '../widget/score_history_item.dart';
import '../widget/score_trend_card.dart';


class TestHistoryScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  const TestHistoryScreen({super.key, required this.clientProfileModel, required this.dietPlanStrategyModel,});
  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  List<WeekRange> _weeks = [];
  int _currentWeekIndex = 0;

  DateTime? _planStart;
  DateTime? _planEnd;

  bool _loading = false;
  String? _error;

  /// All tests fetched from API (for full plan)
  List<Map<String, dynamic>> _allTests = [];

  @override
  void initState() {
    super.initState();



    _buildWeeks();
    _fetchTests(); // 🔹 Call API here
  }

  // ====================== API CALL ======================

  Future<void> _fetchTests() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
          "https://humorstech.com/dietitian/api/app/get_test_data_by_plan.php");

      final body = {
        "dietitian_id": widget.clientProfileModel.dietitianId,
        "profile_id": widget.clientProfileModel.profileId,
        "diet_plan_id": widget.dietPlanStrategyModel.id,
      };

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) {
        setState(() {
          _loading = false;
          _error = "Server error: ${res.statusCode}";
        });
        return;
      }



      final decoded = jsonDecode(res.body);

      if (decoded is! Map || decoded["success"] != true) {
        setState(() {
          _loading = false;
          _error = decoded["message"]?.toString() ?? "Unknown API error";
        });
        return;
      }

      final testsList = decoded["tests"];
      if (testsList is List) {
        _allTests = testsList
            .map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        _allTests = [];
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Failed to load tests: $e";
      });
    }
  }


  void _buildWeeks() {
    try {
      DateTime? start = widget.dietPlanStrategyModel.planStartDate;
      DateTime? end = widget.dietPlanStrategyModel.planEndDate;

      if (end.isBefore(start)) {
        end = start;
      }

      _planStart = start;
      _planEnd = end;

      _weeks = _generateWeekRanges(start, end);

      if (_weeks.isEmpty) {
        _weeks = [WeekRange(start: start, end: end)];
      }

      _currentWeekIndex = _computeInitialWeekIndex();
      setState(() {});
    } catch (e) {
      _weeks = [];
      _planStart = null;
      _planEnd = null;
      setState(() {});
    }
  }

  List<WeekRange> _generateWeekRanges(DateTime start, DateTime end) {
    final List<WeekRange> weeks = [];
    DateTime currentStart = start;

    while (!currentStart.isAfter(end)) {
      DateTime currentEnd = currentStart.add(const Duration(days: 6));
      if (currentEnd.isAfter(end)) currentEnd = end;

      weeks.add(WeekRange(start: currentStart, end: currentEnd));
      currentStart = currentEnd.add(const Duration(days: 1));
    }

    return weeks;
  }

  int _computeInitialWeekIndex() {
    if (_weeks.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < _weeks.length; i++) {
      final w = _weeks[i];
      final start = DateTime(w.start.year, w.start.month, w.start.day);
      final end = DateTime(w.end.year, w.end.month, w.end.day);

      if (!today.isBefore(start) && !today.isAfter(end)) {
        return i;
      }
    }

    final firstStart = DateTime(_weeks.first.start.year,
        _weeks.first.start.month, _weeks.first.start.day);
    final lastEnd = DateTime(
        _weeks.last.end.year, _weeks.last.end.month, _weeks.last.end.day);

    if (today.isBefore(firstStart)) {
      return 0;
    } else if (today.isAfter(lastEnd)) {
      return _weeks.length - 1;
    }

    return 0;
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = d.day.toString().padLeft(2, '0');
    final month = months[d.month - 1];
    return "$day $month";
  }

  String get _fullPlanRangeText {
    if (_planStart == null || _planEnd == null) return "";
    return "${_formatDate(_planStart!)} - ${_formatDate(_planEnd!)}";
  }

  String get _currentWeekRangeText {
    if (_weeks.isEmpty) return "";
    final week = _weeks[_currentWeekIndex];
    return "${_formatDate(week.start)} - ${_formatDate(week.end)}";
  }

  bool _isFutureWeekIndex(int index) {
    if (index < 0 || index >= _weeks.length) return false;
    final w = _weeks[index];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart =
    DateTime(w.start.year, w.start.month, w.start.day);

    return weekStart.isAfter(today);
  }

  List<Map<String, dynamic>> get _currentWeekTests {
    if (_weeks.isEmpty) return [];
    final week = _weeks[_currentWeekIndex];

    final DateTime weekStart =
    DateTime(week.start.year, week.start.month, week.start.day);
    final DateTime weekEnd =
    DateTime(week.end.year, week.end.month, week.end.day);

    return _allTests.where((test) {
      final dtStr = test["date_time"]?.toString();
      if (dtStr == null || dtStr.isEmpty) return false;

      DateTime? testDt;
      try {
        testDt = DateTime.parse(dtStr);
      } catch (_) {
        return false;
      }

      final onlyDate =
      DateTime(testDt.year, testDt.month, testDt.day);

      return !onlyDate.isBefore(weekStart) && !onlyDate.isAfter(weekEnd);
    }).toList();
  }

  // ====================== SCORE SERIES FOR CHART ======================

  /// Build sorted (by date ascending) series for one metric
  List<ScorePoint> _buildSeriesForField(String fieldName) {
    final List<ScorePoint> list = [];

    for (final test in _currentWeekTests) {
      final dtStr = test["date_time"]?.toString();
      if (dtStr == null || dtStr.isEmpty) continue;

      DateTime? testDt;
      try {
        testDt = DateTime.parse(dtStr);
      } catch (_) {
        continue;
      }

      final rawVal = test[fieldName];
      if (rawVal == null) continue;

      final val = double.tryParse(rawVal.toString());
      if (val == null) continue;

      list.add(ScorePoint(testDt, val));
    }

    // sort asc by date so latest is last
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  // ====================== UI ======================

  @override
  Widget build(BuildContext context) {
    final bool canGoPrev = _currentWeekIndex > 0;
    final bool canGoNext = _currentWeekIndex < _weeks.length - 1 && !_isFutureWeekIndex(_currentWeekIndex + 1);


    final series1 = _buildSeriesForField("fat_loss_metabolism_score");



    AppBar appBar(){
      return AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(
              "Test Log",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.30,
              ),
            ),
            if (_planStart != null && _planEnd != null)
              Text(
                _fullPlanRangeText,
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
      );
    }






    if(_weeks.isEmpty){
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: appBar(),
        body:  SafeArea(child: Center(child: Text("No valid plan dates found"))),
      );
    }

    if(_loading){
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: appBar(),
        body:  SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }


    IconButton backWeekIconButton(){
      return  IconButton(
        icon:
        const Icon(Icons.chevron_left_outlined),
        color: canGoPrev
            ? const Color(0xFF252525)
            : Colors.grey.shade400,
        onPressed: canGoPrev
            ? () {
          setState(() {
            _currentWeekIndex--;
          });
        }
            : null,
      );
    }

    IconButton nextWeekIconButton(){
      return  IconButton(
        icon:
        const Icon(Icons.chevron_right_outlined),
        color: canGoNext
            ? const Color(0xFF252525)
            : Colors.grey.shade400,
        onPressed: canGoNext
            ? () {
          setState(() {
            _currentWeekIndex++;
          });
        }
            : null,
      );
    }




    if(_currentWeekTests.isEmpty){
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: appBar(),
        body:  SafeArea(child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 10),
              child: Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    backWeekIconButton(),
                    Column(
                      spacing: 5,
                      children: [
                        Text(
                          "Week ${_currentWeekIndex + 1}",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.20,
                          ),
                        ),
                        Text(
                          _currentWeekRangeText,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.26,
                            letterSpacing: -0.30,
                          ),
                        ),
                      ],
                    ),
                    nextWeekIconButton(),
                  ],
                ),
              ),
            ),
            Expanded(child: Center(
              child: Text("No test data available\nfor this week",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFFA1A1A1),
                fontSize: 25,
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: -1,
              ),
              ),
            )),
          ],
        )),
      );
    }













    return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: appBar(),
        body:SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                child: Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      backWeekIconButton(),
                      Column(
                        spacing: 5,
                        children: [
                          Text(
                            "Week ${_currentWeekIndex + 1}",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.20,
                            ),
                          ),
                          Text(
                            _currentWeekRangeText,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.26,
                              letterSpacing: -0.30,
                            ),
                          ),
                        ],
                      ),
                      nextWeekIconButton(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Column(
                            spacing: 25,
                            children: [
                              scoreTrendCard(title: "Metabolism Score", series: series1,),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 19),
                        child: Text("Score History",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        itemCount: _currentWeekTests.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {

                          final test = _currentWeekTests.reversed.toList()[index];
                          final dateTimeStr = test["date_time"]?.toString() ?? "";
                          dynamic score = test["fat_loss_metabolism_score"] ?? "0";

                          final DateTime dateTime = DateTime.parse(dateTimeStr);
                          return scoreHistoryItemWidget(dateTime:  dateTime, score: score.toInt());


                        }, separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 20);
                      },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }



}
