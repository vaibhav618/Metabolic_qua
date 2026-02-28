import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/utils/score_utils.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/segment_linebar.dart';

class MetabolismTabCard extends StatelessWidget {
  final String metabolismSubtype;
  final int score;

  final String interpretation;
  final String clientState;
  final String ppmNote;
  final ClientProfileModel clientProfileModel;

  const MetabolismTabCard({
    super.key,
    required this.metabolismSubtype,
    required this.score,

    required this.interpretation,
    required this.clientState,
    required this.ppmNote,
    required this.clientProfileModel,
  });

  String _formatDttm(String? dttm) {
    if (dttm == null || dttm.isEmpty) return '';
    try {
      final date = DateTime.parse(dttm).toLocal();
      return DateFormat('d MMM yyyy, h:mma').format(date);
    } catch (_) {
      return dttm;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Score: $score");
    print("metabolismSubtype: $metabolismSubtype");
    final scoreInfo = getScoreLevel(score, metabolismSubtype);

    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.5,
            color: ScoreColorHelper.getScoreColor(score, metabolismSubtype),
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metabolismSubtype,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.72,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Shows how well your metabolism performs for this subtype. Higher scores indicate better metabolic balance.',
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.26,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/images/result_screen/dietitian_result_share.svg",
                  height: 20,
                  width: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF308BF9),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'View trend',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF308BF9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Text(
            _formatDttm(clientProfileModel.dttm),
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.10,
              letterSpacing: -0.20,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$score%',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.60,
                ),
              ),
              const SizedBox(width: 10),
              Container(height: 25, width: 1, color: Colors.black),

              const SizedBox(width: 10),
              Text(
                scoreInfo.label,
                style: GoogleFonts.poppins(
                  color: scoreInfo.color,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.60,
                ),
              ),
            ],
          ),
          // SegmentedScoreBar(
          //   score: score.toDouble(),
          //   metabolismSubtype: metabolismSubtype,
          // ),
          const SizedBox(height: 10),
          Text(
            'Score Meaning',
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.30,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            clientState,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.26,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Interpretation (Metabolic Insight)',
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.30,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            interpretation,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.30,
              letterSpacing: -0.24,
            ),
          ),
        ],
      ),
    );
  }
}
