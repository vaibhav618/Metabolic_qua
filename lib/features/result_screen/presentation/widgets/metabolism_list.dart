import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:respyr_dietitian/features/result_screen/data/models/result_model.dart';
import 'package:respyr_dietitian/features/result_screen/presentation/widgets/metabolism_card.dart';

class MetabolismList extends StatelessWidget {
  final ResultModel result;
  const MetabolismList({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset("assets/images/result_screen/human.svg"),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              MetaCard(
                imageString: "assets/images/result_screen/gut.png",
                metabolismTitle: "Gut Fermentation Metabolism",
                metaScoreSubtitleOne: "Absorptive Metabolism Score",
                metaScoreSubtitleTwo: "Fermentative Metabolism Score",
                metabolismScoreOne: result.gutAbsorptiveScore,
                metabolismScoreTwo: result.gutFermentativeScore,
              ),
              SizedBox(height: 30),
              MetaCard(
                imageString: "assets/images/result_screen/liver.png",
                metabolismTitle: "Glucose \n-Vs- \nFat Metabolism",
                metaScoreSubtitleOne: "Fat Metabolism Score",
                metaScoreSubtitleTwo: "Glucose Metabolism Score",
                metabolismScoreOne: result.fatMetabolismScore,
                metabolismScoreTwo: result.glucoseMetabolismScore,
              ),
              SizedBox(height: 30),
              MetaCard(
                imageString: "assets/images/result_screen/pancreas.png",
                metabolismTitle: "Liver Hepatic Metabolism",
                metaScoreSubtitleOne: "Hepatic Metabolism Score",
                metaScoreSubtitleTwo: "Detoxification Metabolism Score",
                metabolismScoreOne: result.hepaticScore,
                metabolismScoreTwo: result.detoxScore,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
