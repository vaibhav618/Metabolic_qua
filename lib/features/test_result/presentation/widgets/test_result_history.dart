import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/date_helper.dart';
import '../../../test_history/test_history_by_date/data/models/test_data_record.dart';


class TestResultHistory extends StatefulWidget {
  final TestDataRecord testDataRecord;
  const TestResultHistory({super.key, required this.testDataRecord});

  @override
  State<TestResultHistory> createState() => _TestResultHistoryState();
}

class _TestResultHistoryState extends State<TestResultHistory> {
  // Score types (preserve existing strings/behavior)
  static const String _gut = 'Gut';
  static const String _sugar = 'Sugar';
  static const String _liver = 'Liver';

  String selectedScoreType = _gut;

  // Hit zones (preserve your values)
  static const Offset _gutCenter = Offset(132.0, 346.0);   // big circle
  static const Offset _sugarCenter = Offset(149.5, 300.5); // small circle
  static const Offset _liverCenter = Offset(116.0, 279.0); // small circle

  static const double _bigRadius = 100.0;
  static const double _smallRadius = 20.0;

  bool _inside(Offset p, Offset c, double r) => (p - c).distance <= r;

  // ----- Asset / Titles / Labels -----
  String _assetFor(String t) {
    if (t == _gut) return 'assets/images/result_history/result_history_gut.png';
    if (t == _sugar) {
      return 'assets/images/result_history/result_history_sugar.png';
    }
    return 'assets/images/result_history/result_history_liver.png';
  }

  String _headingFor(String t) {
    if (t == _gut) return 'Gut Fermentation Metabolism';
    if (t == _sugar) return 'Glucose -Vs-Fat Metabolism';
    return 'Liver Hepatic Metabolism';
  }

  String _label1For(String t) {
    if (t == _gut) return 'Absorptive\nMetabolism Score';
    if (t == _sugar) return 'Fat Metabolism\nScore';
    return 'Hepatic Metabolism\nScore';
  }

  String _label2For(String t) {
    if (t == _gut) return 'Fermentative\nMetabolism Score';
    if (t == _sugar) return 'Glucose\nMetabolism Score';
    return 'Detoxification\nMetabolism Score';
  }

  // Scores derived from selected type (no UI change; same mapping as your tap logic)
  double _score1For(TestDataRecord r, String t) {
    if (t == _gut) return (r.absorptiveScore ?? 0);
    if (t == _sugar) return (r.fatScore ?? 0);
    return (r.hepaticStressScore ?? 0);
  }

  double _score2For(TestDataRecord r, String t) {
    if (t == _gut) return (r.fermentativeScore ?? 0);
    if (t == _sugar) return (r.glucoseScore ?? 0);
    return (r.detoxScore ?? 0);
  }

  void _handleTapDown(TapDownDetails d) {
    final local = d.localPosition;
    final global = d.globalPosition;

    debugPrint(
      'local: (${local.dx.toStringAsFixed(1)}, ${local.dy.toStringAsFixed(1)})'
          '  global: (${global.dx.toStringAsFixed(1)}, ${global.dy.toStringAsFixed(1)})',
    );

    String type = selectedScoreType;

    // Priority: small zones first, then big zone (preserve logic)
    if (_inside(local, _sugarCenter, _smallRadius)) {
      type = _sugar;
    } else if (_inside(local, _liverCenter, _smallRadius)) {
      type = _liver;
    } else if (_inside(local, _gutCenter, _bigRadius)) {
      type = _gut;
    }

    setState(() => selectedScoreType = type);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.testDataRecord;
    final score1 = _score1For(r, selectedScoreType);
    final score2 = _score2For(r, selectedScoreType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 442,
          child: Stack(
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: _handleTapDown,
                  child: Image.asset(
                    _assetFor(selectedScoreType),
                    width: 192,
                    height: 442,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 0,
                child: SizedBox(
                  height: 442,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest result',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          SvgPicture.asset('assets/images/icons/ic_test_check.svg'),
                          const SizedBox(width: 5),
                          Text(
                            'Completed',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF3EAF58),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.24,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        DateHelper.formatToDateTimeString(widget.testDataRecord.dateTime),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.24,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 198),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 15,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _headingFor(selectedScoreType),
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.10,
                                letterSpacing: -0.72,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _label1For(selectedScoreType),
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.10,
                                letterSpacing: -0.24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  '${score1.toStringAsFixed(2)}%',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 1.26,
                                    letterSpacing: -0.40,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: const Color(0xFF252525),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Good',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF3EAF58),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 1.26,
                                    letterSpacing: -0.40,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: const Color(0xFFA1A1A1),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _label2For(selectedScoreType),
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.10,
                                letterSpacing: -0.24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  '${score2.toStringAsFixed(2)}%',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 1.26,
                                    letterSpacing: -0.40,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: const Color(0xFF252525),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Good',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF3EAF58),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 1.26,
                                    letterSpacing: -0.40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  // Preserve your exact logic (including the typo branch)
                  if (selectedScoreType == _liver) {
                    setState(() => selectedScoreType = _sugar);
                  } else if (selectedScoreType == _sugar) {
                    setState(() => selectedScoreType = _gut);
                  } else {
                    setState(() => selectedScoreType = _liver);
                  }
                },
                icon: const Icon(CupertinoIcons.left_chevron),
              ),
              Container(
                decoration: ShapeDecoration(
                  color: const Color(0xFFF0F0F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => selectedScoreType = _gut),
                      child: Container(
                        decoration: selectedScoreType == _gut
                            ? ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        )
                            : null,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/icons/ic_gut.svg',
                              colorFilter: ColorFilter.mode(
                                selectedScoreType == _gut
                                    ? const Color(0xFF308BF9)
                                    : const Color(0xFFA1A1A1),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Visibility(
                              visible: selectedScoreType == _gut,
                              child: Text(
                                'Gut',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.10,
                                  letterSpacing: -0.24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => selectedScoreType = _sugar),
                      child: Container(
                        decoration: selectedScoreType == _sugar
                            ? ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        )
                            : null,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/icons/ic_sugar.svg',
                              colorFilter: ColorFilter.mode(
                                selectedScoreType == _sugar
                                    ? const Color(0xFF308BF9)
                                    : const Color(0xFFA1A1A1),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Visibility(
                              visible: selectedScoreType == _sugar,
                              child: Text(
                                'Sugar',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.10,
                                  letterSpacing: -0.24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => selectedScoreType = _liver),
                      child: Container(
                        decoration: selectedScoreType == _liver
                            ? ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        )
                            : null,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/icons/ic_liver.svg',
                              colorFilter: ColorFilter.mode(
                                selectedScoreType == _liver
                                    ? const Color(0xFF308BF9)
                                    : const Color(0xFFA1A1A1),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Visibility(
                              visible: selectedScoreType == _liver,
                              child: Text(
                                'Liver',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.10,
                                  letterSpacing: -0.24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Preserve your exact right-arrow logic (no UI/logic change)
                  if (selectedScoreType == _gut) {
                    setState(() => selectedScoreType = _sugar);
                  } else if (selectedScoreType == _sugar) {
                    setState(() => selectedScoreType = _liver);
                  } else {
                    setState(() => selectedScoreType = _gut);
                  }
                },
                icon: const Icon(CupertinoIcons.right_chevron),
              ),
            ],
          ),
        ),
        const SizedBox(height: 35),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("View test result",
              style: GoogleFonts.poppins(
                color: const Color(0xFF308BF9),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: -0.30,
              ),
            ),
            Icon(Icons.keyboard_arrow_right_outlined,   color: const Color(0xFF308BF9),
            )
          ],
        )
      ],
    );
  }
}
