import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/segment_linebar.dart';

class MetabolismTabCardNew extends StatelessWidget {
  final String metabolismSubtype;
  final double score;
  final String interpretation;
  final String clientState;
  final ClientProfileModel clientProfileModel;
  final String scoreZone; // kept for compatibility (not used for UI now)
  final String whyIsThisScore;
  final bool isRange1;
  final String resultDateAndTime;

  const MetabolismTabCardNew({
    super.key,
    required this.metabolismSubtype,
    required this.score,
    required this.interpretation,
    required this.clientState,
    required this.clientProfileModel,
    required this.scoreZone,
    required this.whyIsThisScore,
    required this.isRange1, required this.resultDateAndTime,
  });


  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(dateTime);
      final local = dt.toLocal();
      return DateFormat('d MMM yyyy, h:mma').format(local);
    } catch (_) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {


     Color zoneColor(String zone) {
      final z = zone.trim().toLowerCase();

      switch (z) {
        case "optimal":
          return const Color(0xFF3FAF58);
        case "moderate":
          return const Color(0xFFFFBF2D);
        case "focus":
          return const Color(0xFFE48326);
        default:
          return const Color(0xFF535359); // fallback (grey)
      }
    }


    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: rh(context: context, px: 0.5),
            color: zoneColor(scoreZone),
          ),
          borderRadius: BorderRadius.circular(
            rh(context: context, px: 15),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: rh(context: context, px: 13),
        vertical: rh(context: context, px: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metabolismSubtype,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 18),
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: rh(context: context, px: -0.72),
            ),
          ),

          SizedBox(height: rh(context: context, px: 10)),

          Text(
            whyIsThisScore,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: rh(context: context, px: 12),
              fontWeight: FontWeight.w400,
              height: 1.26,
              letterSpacing: rh(context: context, px: -0.24),
            ),
          ),

          SizedBox(height: rh(context: context, px: 10)),
          const Divider(),
          SizedBox(height: rh(context: context, px: 10)),

          Text(
            formatDateTime(resultDateAndTime),
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: rh(context: context, px: 10),
              fontWeight: FontWeight.w400,
              height: 1.10,
              letterSpacing: rh(context: context, px: -0.20),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${score.toStringAsFixed(0)}%",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 30),
                  fontWeight: FontWeight.w600,
                  letterSpacing: rh(context: context, px: -0.60),
                ),
              ),

              SizedBox(width: rh(context: context, px: 10)),

              Container(
                height: rh(context: context, px: 25),
                width: rh(context: context, px: 1),
                color: Colors.black,
              ),

              SizedBox(width: rh(context: context, px: 10)),

              Text(
                scoreZone,
                style: GoogleFonts.poppins(
                  color: zoneColor(scoreZone),
                  fontSize: rh(context: context, px: 30),
                  fontWeight: FontWeight.w600,
                  letterSpacing: rh(context: context, px: -0.60),
                ),
              ),
            ],
          ),

          SegmentedScoreBar(
            score: score.toDouble(),
            isRange1: isRange1, zone: scoreZone,
          ),

          SizedBox(height: rh(context: context, px: 10)),

          Text(
            'Trend Meaning',
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 12),
              fontWeight: FontWeight.w600,
              height: 1.30,
              letterSpacing: rh(context: context, px: -0.24),
            ),
          ),

          SizedBox(height: rh(context: context, px: 5)),

          Text(
            clientState,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 12),
              fontWeight: FontWeight.w400,
              height: 1.26,
              letterSpacing: rh(context: context, px: -0.24),
            ),
          ),
        ],
      ),
    );
  }
}
