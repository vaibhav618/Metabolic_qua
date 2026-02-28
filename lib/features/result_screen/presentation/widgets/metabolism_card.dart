import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/utils/score_utils.dart';

class MetaCard extends StatelessWidget {
  final String imageString;
  final String metabolismTitle;
  final String metaScoreSubtitleOne;
  final String metaScoreSubtitleTwo;
  final double metabolismScoreOne;
  final double metabolismScoreTwo;
  const MetaCard({
    super.key,
    required this.imageString,
    required this.metabolismTitle,
    required this.metaScoreSubtitleOne,
    required this.metaScoreSubtitleTwo,
    required this.metabolismScoreOne,
    required this.metabolismScoreTwo,
  });

  @override
  Widget build(BuildContext context) {
    final scoreInfoOne = getScoreLevel(
      metabolismScoreOne as int,
      metaScoreSubtitleOne,
    );
    final scoreInfoTwo = getScoreLevel(
      metabolismScoreTwo as int,
      metaScoreSubtitleTwo,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Image.asset(imageString, height: 24, width: 24),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  metabolismTitle,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metaScoreSubtitleOne,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                            height: 1.10,
                            letterSpacing: -0.16,
                          ),
                        ),
                        SizedBox(height: 5),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '${metabolismScoreOne.toStringAsFixed(0)}%',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.10,
                                  letterSpacing: -0.24,
                                ),
                              ),
                              VerticalDivider(
                                color: Color(0xFF252525),
                                width: 2,
                              ),
                              Text(
                                scoreInfoOne.label,
                                style: GoogleFonts.poppins(
                                  color: scoreInfoOne.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.10,
                                  letterSpacing: -0.24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(color: Color(0xFF252525), width: 2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metaScoreSubtitleTwo,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                            height: 1.10,
                            letterSpacing: -0.16,
                          ),
                        ),
                        SizedBox(height: 5),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '${metabolismScoreTwo.toStringAsFixed(0)}%',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.10,
                                  letterSpacing: -0.24,
                                ),
                              ),
                              VerticalDivider(
                                color: Color(0xFF252525),
                                width: 2,
                              ),
                              Text(
                                scoreInfoTwo.label,
                                style: GoogleFonts.poppins(
                                  color: scoreInfoTwo.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.10,
                                  letterSpacing: -0.24,
                                ),
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
        ],
      ),
    );
  }
}
