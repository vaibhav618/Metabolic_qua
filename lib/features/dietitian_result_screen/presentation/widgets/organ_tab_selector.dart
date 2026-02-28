import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_state.dart';

import '../cubit/dietitian_result_cubit.dart';

class OrganTabSelector extends StatelessWidget {
  const OrganTabSelector({super.key});

  final List<Map<String, String>> organs = const [
    {
      "label": "Gut",
      "icon": "assets/images/result_screen/dietitian_gut_outline.svg",
    },
    {
      "label": "Liver",
      "icon": "assets/images/result_screen/dietitian_liver_outline.svg",
    },
    {
      "label": "Fat",
      "icon": "assets/images/result_screen/dietitian_pancreas_outline.svg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DietitianResultCubit, DietitianResultState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              organs.map((organ) {
                final isSelected =
                    state.selectedTab.toLowerCase() ==
                    organ['label']!.toLowerCase();

                return GestureDetector(
                  onTap: () {
                    context.read<DietitianResultCubit>().changeTab(
                      organ['label']!,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,

                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          organ['icon']!,
                          colorFilter: ColorFilter.mode(
                            isSelected ? Color(0xFF308BF9) : Color(0xFFA1A1A1),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 2),
                        if (isSelected) ...[
                          const SizedBox(height: 6),
                          Text(
                            organ['label']!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF252525),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
