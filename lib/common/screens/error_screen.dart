import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorScreen extends StatefulWidget {
  final String errorMessage;
  const ErrorScreen({super.key, required this.errorMessage});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {


  @override
  Widget build(BuildContext context) {


    String getErrorMessage(String message){
      if(message.contains("Client profile not found")){
        return "User not found";
      }
      return "Unknown error";
    }


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Image.asset("assets/images/common/img_404_error.png"),
            SizedBox(height: 96,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  getErrorMessage(widget.errorMessage),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 0.75,
                    letterSpacing: -0.56,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  getErrorMessage(widget.errorMessage),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.60,
                  ),
                ),
              ),
            ),
            SizedBox(height: 60,),
            ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF308BF9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50000),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 25,vertical: 16)
                ),
                child: Text("Try again",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.10,
                    letterSpacing: 0.30,
                  ),
                )
            ),

          ],
        ),
      ),
    );
  }
}
