import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  final String loadingMessage;
  const LoadingWidget({super.key, required this.loadingMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.progressiveDots(
            color: const Color(0xFF308BF9),
            size: 50,
          ),
          SizedBox(height: 10,),
          Text(loadingMessage,style: GoogleFonts.poppins(fontSize: 12),)
        ],
      ),
    );
  }
}
