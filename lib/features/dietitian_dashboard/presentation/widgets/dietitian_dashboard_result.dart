import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_cubit.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/widgets/swipe_button_widget.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/organ_tab_selector.dart';

class DietitianDashboardResult extends StatelessWidget {
  const DietitianDashboardResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            "Today's Result",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.check_circle_sharp,
                color: Colors.green,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Completed',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF3EAF58),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '05 Jul, 12:30pm',
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          ),
          SizedBox(height: 30),

          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            margin: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(154),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              color: Colors.white,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gut Fermentation Metabolism',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                    letterSpacing: -0.72,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Absorptive Metabolism Score',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.10,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '97%',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.26,
                    letterSpacing: -0.40,
                  ),
                ),
                SizedBox(height: 16),
                Divider(color: Colors.black),
                SizedBox(height: 16),
                Text(
                  'Fermentative Metabolism Score',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.10,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '3%',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.26,
                    letterSpacing: -0.40,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: Color(0xFFEEFFF1),
                      ),
                      child: Text(
                        'Good',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF3EAF58),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.26,
                          letterSpacing: -0.30,
                        ),
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(
                        "assets/images/common/dietitian_share.svg",
                      ),
                    ),
                    SizedBox(width: 5),
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(
                        "assets/images/common/dietitian_info.svg",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                 // context.read<TestResultCubit>().previousTab();
                },

                icon: SvgPicture.asset("assets/images/common/left_icon.svg"),
              ),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const OrganTabSelector(),
              ),

              IconButton(
                onPressed: () {
                //  context.read<TestResultCubit>().nextTab();
                },
                icon: SvgPicture.asset("assets/images/common/right_button.svg"),
              ),
            ],
          ),

          SizedBox(height: 30),
          Center(
            child: BlocProvider.value(
              value: context.read<DietitianDashboardCubit>(),
              child: const SwipeButtonWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
