import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:intl/intl.dart" show DateFormat;

import '../../bloc/test_data_bloc.dart';
import '../../bloc/test_data_event.dart';
import '../../bloc/test_data_state.dart';
import '../widgets/test_data_list.dart';

class TestDataPage extends StatefulWidget {
  final String initialProfileId; // e.g., 'profile1'
  final DateTime initialDate;
  final DateTime startDate;// e.g., DateTime.now()

  const TestDataPage({
    super.key,
    required this.initialProfileId,
    required this.initialDate, required this.startDate,
  });

  @override
  State<TestDataPage> createState() => _TestDataPageState();
}

class _TestDataPageState extends State<TestDataPage> {
  late final TextEditingController _profileController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _profileController = TextEditingController(text: widget.initialProfileId);
    _selectedDate = widget.initialDate;
    _fetch();
  }

  void _fetch() {
    context.read<TestDataBloc>().add(
      FetchTestData(profileId: _profileController.text.trim(), date: _selectedDate),
    );
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 2);
    final last = DateTime(now.year + 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = getDateList(widget.startDate).reversed.toList(); // compute once
    final df = DateFormat('yyyy-MM-dd');
    final dateLabel = df.format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        title: Text("Test history",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        ),
      ),
      body: SafeArea(
        child: Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / 7;
                    return Container(
                      height: 60,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                      width: double.infinity,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 0),
                        itemBuilder: (context, index) {
                          final date = dates[dates.length - 1 - index];
                          final dStr = df.format(date);
                          final isSelected = dStr == dateLabel;

                          final dayStr = DateFormat('dd').format(date);   // "08"
                          final monthStr = DateFormat('MMM').format(date); // "Aug"

                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedDate = date);
                              _fetch();
                            },
                            child: Container(
                              width: itemWidth, // ensures 7 items fit the row
                              alignment: Alignment.center,
                              decoration: ShapeDecoration(
                                color: isSelected ? const Color(0xFF308BF9) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected
                                        ? const Color(0xFF2F80ED)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayStr,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color:isSelected? Colors.white:  Color(0xFF252525),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.26,
                                      letterSpacing: -0.30,
                                    ),
                                  ),
                                  Text(
                                    monthStr,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color:isSelected? Colors.white:  Color(0xFF252525),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<TestDataBloc, TestDataState>(
                  builder: (context, state) {
                    if (state is TestDataLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TestDataError) {
                      return Center(child: Text('Error: ${state.message}'));
                    } else if (state is TestDataEmpty) {
                      return const Center(child: Text('No data for selected date.'));
                    } else if (state is TestDataLoaded) {
                      return TestDataList(records: state.records);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  List<DateTime> getDateList(DateTime startDate) {
    final today = DateTime.now();
    final dates = <DateTime>[];

    // Generate from startDate to today
    DateTime current = startDate;
    while (!current.isAfter(today)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    if (dates.length < 7) {
      // Add 3 items before startDate
      DateTime before = startDate.subtract(const Duration(days: 1));
      for (int i = 0; i < 3; i++) {
        dates.insert(0, before);
        before = before.subtract(const Duration(days: 1));
      }

      // If still less than 7, add at the end
      DateTime after = today.add(const Duration(days: 1));
      while (dates.length < 7) {
        dates.add(after);
        after = after.add(const Duration(days: 1));
      }
    }

    return dates;
  }

}
