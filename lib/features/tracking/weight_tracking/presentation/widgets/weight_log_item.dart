import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WeightLogItem extends StatelessWidget {
  final double weight;
  final DateTime dateTime;
  final String weightProgress; // on_track / off_track
  final VoidCallback onDeleteWeightLogPressed;

  const WeightLogItem({
    super.key,
    required this.weight,
    required this.dateTime,
    required this.weightProgress,
    required this.onDeleteWeightLogPressed,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("d MMM yyyy hh:mm a").format(dateTime);
    // Example → 12 Nov 2025 06:45 PM

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 0),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              Row(
                spacing: 10,
                children: [
                  Text(
                    "${weight.toStringAsFixed(1)} Kg",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      letterSpacing: -0.72,
                    ),
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      if (weightProgress == "on_track") ...[
                        const Icon(
                          CupertinoIcons.arrowtriangle_up_fill,
                          color: Color(0xFF3EAF58),
                          size: 8,
                        ),
                        Text(
                          "On track",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF3EAF58),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ] else if (weightProgress == "off_track") ...[
                        const Icon(
                          CupertinoIcons.arrowtriangle_down_fill,
                          color: Color(0xFFDA5747),
                          size: 8,
                        ),
                        Text(
                          "Off track",
                          style: GoogleFonts.poppins(
                            color: Color(0xFFDA5747),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ] else ...[
                        const SizedBox.shrink(),
                      ],
                    ],
                  ),
                ],
              ),
              Text(
                formattedDate,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  height: 1,
                  letterSpacing: -0.20,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onDeleteWeightLogPressed,
            icon: const Icon(CupertinoIcons.delete_simple),
            color: const Color(0xFF252525),
          )
        ],
      ),
    );
  }
}
