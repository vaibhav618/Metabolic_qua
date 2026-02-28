import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart';
import '../../../bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';
import '../cubit/dietitian_result_state.dart';

class ResultOverviewCard extends StatelessWidget {
  final String metabolismType;
  final DietitianResultState state;
  final TestResultResponse result;

  const ResultOverviewCard({
    super.key,
    required this.metabolismType,
    required this.state,
    required this.result,
  });

  static final Map<String, String> _metabolismTitle = {
    "Gut": "Digestive\nBalance Trends",
    "Fat": "Fuel & Energy\nTrends",
    "Liver": "Metabolic\nRecovery Trends",
  };

  static final Map<String, String> _metabolismSubTypeOne = {
    "Gut": "Nutrient\nUtilization Trend",
    "Fat": "Fuel\nUtilization Trend",
    "Liver": "Recovery\nActivity Trend",

  };

  static final Map<String, String> _metabolismSubTypeTwo = {
    "Gut": "Digestive\nActivity Trend",
    "Fat": "Energy\nSource Trend",
    "Liver": "Metabolic\nLoad Trend",
  };

  Map<String, double> _getScores(TestResultResponse result) {
    final metabolism = result.respyrResponse.metabolismScoreAnalysis;

    switch (metabolismType) {
      case "Gut":
        return {
          "one": metabolism.nutrientUtilizationTrend.score,
          "two": metabolism.digestiveActivityTrend.score,
        };
      case "Fat":
        return {
          "one": metabolism.fuelUtilizationTrend.score,
          "two": metabolism.energySourceTrend.score,
        };
      case "Liver":
        return {
          "one": metabolism.recoveryActivityTrend.score,
          "two": metabolism.metabolicLoadTrend.score,
        };
      default:
        return {"one": 0.0, "two": 0.0};
    }
  }

  Map<String, String> _getZones(TestResultResponse result) {
    final metabolism = result.respyrResponse.metabolismScoreAnalysis;
    String safe(String? v) => v ?? '';

    switch (metabolismType) {
      case "Gut":
        return {
          "one": safe(metabolism.nutrientUtilizationTrend.zone),
          "two": safe(metabolism.digestiveActivityTrend.zone),
        };
      case "Fat":
        return {
          "one": safe(metabolism.fuelUtilizationTrend.zone),
          "two": safe(metabolism.energySourceTrend.zone),
        };
      case "Liver":
        return {
          "one": safe(metabolism.recoveryActivityTrend.zone),
          "two": safe(metabolism.metabolicLoadTrend.zone),
        };
      default:
        return {"one": '', "two": ''};
    }
  }

  Color _zoneColor(String zone) {
    switch (zone.toLowerCase()) {
      case 'focus':
        return const Color(0xFFE48326);
      case 'moderate':
        return const Color(0xFFFFBF2D);
      case 'optimal':
        return const Color(0xFF3EAF58);
      default:
        return const Color(0xFF252525);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scores = _getScores(result);
    final zones = _getZones(result);

    final double score1 = scores["one"] ?? 0.0;
    final double score2 = scores["two"] ?? 0.0;

    final zone1 = zones["one"] ?? '';
    final zone2 = zones["two"] ?? '';

    final zoneColor1 = _zoneColor(zone1);
    final zoneColor2 = _zoneColor(zone2);

    return Container(
      width: MediaQuery.of(context).size.width * 0.66,
      padding: EdgeInsets.symmetric(
        horizontal: rh(context: context, px: 16),
        vertical: rh(context: context, px: 20),
      ),
      margin: EdgeInsets.only(left: rh(context: context, px: 10)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rh(context: context, px: 10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(74),
            blurRadius: rh(context: context, px: 10),
            spreadRadius: rh(context: context, px: 2),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _metabolismTitle[metabolismType] ?? "",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 10),
              fontWeight: FontWeight.w600,
              height: 1.10,
            ),
          ),
          SizedBox(height: rh(context: context, px: 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _scoreSection(
                  context,
                  title: _metabolismSubTypeOne[metabolismType] ?? "",
                  score: score1,
                  zone: zone1,
                  zoneColor: zoneColor1,
                ),
              ),
              SizedBox(width: rh(context: context, px: 10)),
              Container(
                height: rh(context: context, px: 40),
                width: rh(context: context, px: 1),
                color: Colors.black,
              ),
              SizedBox(width: rh(context: context, px: 10)),
              Expanded(
                child: _scoreSection(
                  context,
                  title: _metabolismSubTypeTwo[metabolismType] ?? "",
                  score: score2,
                  zone: zone2,
                  zoneColor: zoneColor2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreSection(
      BuildContext context, {
        required String title,
        required double score,
        required String zone,
        required Color zoneColor,
      }) {
    final scoreText = score.toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.start,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 8),
            fontWeight: FontWeight.w400,
            height: 1.10,
            letterSpacing: rh(context: context, px: -0.16),
          ),
        ),
        SizedBox(height: rh(context: context, px: 5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$scoreText%',
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 12),
                fontWeight: FontWeight.w700,
                height: 1.10,
              ),
            ),
            Container(
              height: rh(context: context, px: 10),
              width: rh(context: context, px: 1),
              color: Colors.black,
            ),
            Text(
              zone,
              style: GoogleFonts.poppins(
                color: zoneColor,
                fontSize: rh(context: context, px: 12),
                fontWeight: FontWeight.w700,
                height: 1.10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
