import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/size/get_height.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_state.dart';

class ExhaleFailed extends StatelessWidget {
  final BluetoothExhaleState state;
  final VoidCallback onStartAgain;

  const ExhaleFailed({
    super.key,
    required this.state,
    required this.onStartAgain,
  });

  bool _contains(String s, String q) =>
      s.toLowerCase().contains(q.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final err = (state.error ?? "").trim();
    final e = err.toLowerCase();

    final isInhale = _contains(e, "inhaled") || _contains(e, "inhale");
    final isDropped = _contains(e, "stopped");
    final timeout = _contains(e, "no exhale detected within 30 seconds");

    if (isInhale) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You breathed air in\nInstead of out",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
            SizedBox(height: rh(context: context, px: 37)),
            Expanded(
              child: Image.asset(
                "assets/images/device_connection/img_inhale_exhale_screen.png",
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    onStartAgain();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308BF9),
                      padding: EdgeInsetsGeometry.symmetric(
                          vertical: rh(context: context, px: 16)),
                      elevation: 0),
                  child: Text(
                    "Start Again",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: rh(context: context, px: 15),
                        fontWeight: FontWeight.w700,
                        height: rh(context: context, px: 1.0),
                        letterSpacing: rh(context: context, px: 0.30)),
                  )),
            ),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }
    if (isDropped) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          children: [
            Spacer(),
            Center(
                child: Image.asset(
              "assets/images/device_connection/img_inhale_exhale_dropped.png",
            )),
            SizedBox(
              height: rh(context: context, px: 48),
            ),
            Center(
              child: Text(
                "Keep the ball in the\nrange for longer",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 25),
                  fontWeight: FontWeight.w600,
                  height: rh(context: context, px: 1.29),
                  letterSpacing: rh(context: context, px: -1),
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    onStartAgain();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308BF9),
                      padding: EdgeInsetsGeometry.symmetric(
                          vertical: rh(context: context, px: 16)),
                      elevation: 0),
                  child: Text(
                    "Start Again",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: rh(context: context, px: 15),
                        fontWeight: FontWeight.w700,
                        height: rh(context: context, px: 1.0),
                        letterSpacing: rh(context: context, px: 0.30)),
                  )),
            ),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    if (timeout) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You took too long to\nexhale.",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
            SizedBox(height: rh(context: context, px: 37)),
            Expanded(
              child: Image.asset(
                "assets/images/device_connection/img_exhale_timeout.png",
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    onStartAgain();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308BF9),
                      padding: EdgeInsetsGeometry.symmetric(
                          vertical: rh(context: context, px: 16)),
                      elevation: 0),
                  child: Text(
                    "Start Again",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: rh(context: context, px: 15),
                        fontWeight: FontWeight.w700,
                        height: rh(context: context, px: 1.0),
                        letterSpacing: rh(context: context, px: 0.30)),
                  )),
            ),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();

    // return Padding(
    //   padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text("Something went wrong.",
    //         style: GoogleFonts.poppins(
    //           color: const Color(0xFF252525),
    //           fontSize: rh(context: context, px: 25),
    //           fontWeight: FontWeight.w600,
    //           height: rh(context: context, px: 1.29),
    //           letterSpacing: rh(context: context, px: -1),
    //         ),
    //       ),
    //       SizedBox(height: rh(context: context, px: 25),),
    //       Text("Don’t worry—let’s give it another try.",
    //         style: GoogleFonts.poppins(
    //           color: const Color(0xFF535359),
    //           fontSize: rh(context: context, px: 15),
    //           fontWeight: FontWeight.w400,
    //           height: rh(context: context, px: 1.30),
    //           letterSpacing: rh(context: context, px: -0.30),
    //         ),
    //       ),
    //       SizedBox(height: rh(context: context, px: 37)),
    //       Expanded(child: Container(),),
    //       SizedBox(
    //         width: double.infinity,
    //         child: ElevatedButton(
    //             onPressed: (){
    //               onStartAgain();
    //             },
    //             style: ElevatedButton.styleFrom(
    //                 backgroundColor: const Color(0xFF308BF9),
    //                 padding: EdgeInsetsGeometry.symmetric(vertical: rh(context: context, px: 16)),
    //                 elevation: 0
    //             ),
    //             child: Text("Start Again",
    //               style: GoogleFonts.poppins(
    //                   color: Colors.white,
    //                   fontSize: rh(context: context, px: 15),
    //                   fontWeight: FontWeight.w700,
    //                   height: rh(context: context, px: 1.0),
    //                   letterSpacing: rh(context: context, px: 0.30)
    //               ),
    //             )
    //         ),
    //       ),
    //       SizedBox(height: rh(context: context, px: 20),),
    //     ],
    //   ),
    // );
  }
}
