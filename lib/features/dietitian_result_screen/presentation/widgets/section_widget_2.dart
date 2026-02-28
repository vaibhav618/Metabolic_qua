import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_state.dart';

import '../../../../core/size/get_height.dart';
import '../../../bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';
import 'metabolism_tab_card_new.dart';

class SectionWidgetNew extends StatelessWidget {
  // final GlobalKey sectionKey;
  final String metabolismType;
  final DietitianResultState state;
  final ClientProfileModel clientProfileModel;
  final TestResultResponse result;
  final BuildContext context;

  const SectionWidgetNew({
    super.key,
    // required this.sectionKey,
    required this.metabolismType,
    required this.state,
    required this.clientProfileModel,
    required this.result,
    required this.context,
  });

  static final Map<String, String> _metabolismTitle = {
    "Gut": "Digestive Balance Trends",
    "Fat": "Fuel & Energy Trends",
    "Liver": "Metabolic Recovery Trends",
  };

  static final Map<String, List<String>> _metabolismSubTypes = {
    "Gut": ["Nutrient Utilization Trend", "Digestive Activity"],
    "Fat": ["Fuel Utilization Trend", "Energy Source Trend"],
    "Liver": [  "Recovery Activity Trend","Metabolic Load Trend",],
  };

  // Range1: 80–100 optimal, 70–79.9 moderate, <70 focus
  static const Set<String> _range1Types = {
    "fuel utilization trend",
    "nutrient utilization trend",
    "recovery activity trend",
  };

  bool _isRange1(String subtype) {
    final n = subtype.toLowerCase().trim();
    return _range1Types.contains(n);
  }

  @override
  Widget build(BuildContext context) {
    final subTypes = _metabolismSubTypes[metabolismType] ?? [];
    if (subTypes.length < 2) return const SizedBox();

    final metabolism = result.respyrResponse.metabolismScoreAnalysis;

    final metab1 = switch (metabolismType) {
      "Gut" => metabolism.nutrientUtilizationTrend,
      "Fat" => metabolism.fuelUtilizationTrend,
      "Liver" => metabolism.recoveryActivityTrend,
      _ => metabolism.nutrientUtilizationTrend,
    };

    final metab2 = switch (metabolismType) {
      "Gut" => metabolism.digestiveActivityTrend,
      "Fat" => metabolism.energySourceTrend,
      "Liver" => metabolism.metabolicLoadTrend,

      _ => metabolism.digestiveActivityTrend,
    };

    final metab1Subtype = subTypes[0];
    final metab2Subtype = subTypes[1];

    final metab1IsRange1 = _isRange1(metab1Subtype);
    final metab2IsRange1 = _isRange1(metab2Subtype);



    return Container(
      // key: sectionKey,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.only(top: rh(context: context, px: 10)),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDEE2E6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MetabolismTabCardNew(
                  metabolismSubtype: metab1Subtype,
                  score: metab1.score,
                  interpretation: metab1.interpretation,
                  clientState: metab1.clientState,
                  clientProfileModel: clientProfileModel,
                  scoreZone: metab1.zone,
                  whyIsThisScore: metab1.whatIsThisScore,
                  isRange1: metab1IsRange1, resultDateAndTime: result.dateTime,
                ),
                const SizedBox(height: 15),
                MetabolismTabCardNew(
                  metabolismSubtype: metab2Subtype,
                  score: metab2.score,
                  interpretation: metab2.interpretation,
                  clientState: metab2.clientState,
                  clientProfileModel: clientProfileModel,
                  scoreZone: metab2.zone,
                  whyIsThisScore: metab2.whatIsThisScore,
                  isRange1: metab2IsRange1, resultDateAndTime: result.dateTime,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              color: Colors.white,
              child: Row(
                children: [
                  Text(
                    _metabolismTitle[metabolismType] ?? '',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
