import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar commonAppbar({required String title, required VoidCallback onBackButtonPress}){
  return AppBar(
    automaticallyImplyLeading:false,
    backgroundColor: Color(0xFFF5F7FA),
    surfaceTintColor: Color(0xFFF5F7FA),
    title: Row(
      children: [
        InkWell(onTap: (){onBackButtonPress;}, child: Icon(Icons.arrow_back_outlined), ),
        SizedBox(width: 20,),
        Text(title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        )
      ],
    ),
  );
}