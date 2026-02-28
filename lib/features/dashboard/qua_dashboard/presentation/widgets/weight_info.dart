import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/weight_pogress_bar.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/weight_progress_badge.dart';

class WeightInfo extends StatelessWidget {
  const WeightInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: ShapeDecoration(
          color: const Color(0xFFE1E6ED),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Current Weight",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.24,
                            height: 1.0
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 10,
                        children: [
                          Text("75",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: 100,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -2,
                                height: 1.0
                            ),
                          ),
                          Text("Kg",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 3,
                              letterSpacing: -0.40,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  SvgPicture.asset("assets/images/icons/ic_weight.svg", width: 24, height: 24,color:  Color(0xFF535359),)
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  Text("0.5Kg",
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.30,
                        height: 1.0
                    ),
                  ),
                  SvgPicture.asset("assets/images/icons/ic_progress_up.svg"),
                  Text("gained than yesterday",
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.24,
                        height: 1.0
                    ),
                  )
                ],
              ),
              SizedBox(height: 32,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF252525),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    elevation: 0
                ),
                onPressed: () {  },
                child:   Text(
                  'Update Weight',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.10,
                    letterSpacing: 0.30,
                  ),
                ),
              ),
              SizedBox(height: 28,),
              WeightProgressBadgeCurrent(currentWeight: 68.5, targetedWeight: 70, initialWeight: 70,)
            ],
          ),
        ),
      ),
    );
  }
}
