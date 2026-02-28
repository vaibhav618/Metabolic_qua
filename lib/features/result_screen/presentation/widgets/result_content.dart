import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/result_screen/data/models/result_model.dart';
import 'package:respyr_dietitian/features/result_screen/presentation/widgets/metabolism_list.dart';

class ResultContent extends StatelessWidget {
  final ResultModel result;
  const ResultContent({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFFC7C6CE), width: 1),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Text(
                            'Current BMI',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.10,
                              letterSpacing: -0.24,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '25kg/m',
                                  style: TextStyle(
                                    color: const Color(0xFF535359),
                                    fontSize: 20,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                  ),
                                ),
                                TextSpan(
                                  text: '2',
                                  style: TextStyle(
                                    color: const Color(0xFF535359),
                                    fontSize: 20,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                    fontFeatures: [FontFeature.enable("sups")],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      VerticalDivider(color: Color(0xFFC7C6CE), width: 2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Current BMR',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.10,
                              letterSpacing: -0.24,
                            ),
                          ),

                          Text(
                            '1827 cal',
                            style: TextStyle(
                              color: const Color(0xFF535359),
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFFC7C6CE), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFEA5455),
                        shape: OvalBorder(),
                      ),
                    ),
                    SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Poor\t\t',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Color(0xFF252525),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '0 - 60%',
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              color: Color(0xFF535359),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFFC412),
                        shape: OvalBorder(),
                      ),
                    ),
                    SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Fair\t\t',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Color(0xFF252525),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '61 - 79%',
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              color: Color(0xFF535359),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF3EAF58),
                        shape: OvalBorder(),
                      ),
                    ),
                    SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Good\t\t',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Color(0xFF252525),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '80 - 100%',
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              color: Color(0xFF535359),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
        MetabolismList(result: result),
        SizedBox(height: 20),
        Text("Quick Summary"),
      ],
    );
  }
}
