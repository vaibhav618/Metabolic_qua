import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import '../widgets/profile_card.dart';

class WhoIsUsingScreen extends StatelessWidget {
  const WhoIsUsingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF308BF9),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            rh(context: context, px: 17),
            rh(context: context, px: 55),
            rh(context: context, px: 17),
            0,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Who’s using Respyr today?",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: rh(context: context, px: 34),
                      fontWeight: FontWeight.w400,
                      letterSpacing: rh(context: context, px: -2.04),
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 39)),
                  Text(
                    "Featured",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: rh(context: context, px: 25),
                      fontWeight: FontWeight.w600,
                      letterSpacing: rh(context: context, px: -1),
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 30)),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: rh(context: context, px: 10),
                      mainAxisSpacing: rh(context: context, px: 10),
                      children: List.generate(
                        10,
                            (index) => ProfileCard(
                          isProfileAvailable: index <= 3,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
              Positioned(
                bottom: 0,
                child: IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF252525),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.all(rh(context: context, px: 20))
                    ),
                    icon: Icon(Icons.close, color: Colors.white,)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}