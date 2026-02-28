import 'package:cupertino_battery_indicator/cupertino_battery_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BatteryIconWidget extends StatelessWidget {
  final double batteryPercentage;


  const BatteryIconWidget({
    super.key,
    required this.batteryPercentage,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: ShapeDecoration(
        color: const Color(0xFFF5F7FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        spacing: 10,
        children: [
          BatteryIndicator(
            value: batteryPercentage/100,
            trackHeight: 12,
            barColor: batteryPercentage <= 20 ?   Colors.red : Colors.green,
            trackBorderColor: const Color(0xFF252525),
          ),
          Visibility(
            visible: false,
            child: Text("${batteryPercentage.toInt()}%",
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: -0.20,
              ),
            ),
          )
        ],
      ),
    );
  }
}


