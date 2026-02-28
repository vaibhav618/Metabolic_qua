import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../client_login_manager/client_login_manager.dart';
import '../../../../../common/dialogs/floating_message.dart';
import '../../../../../routes/app_routes.dart';
import '../../bloc/qua_dashboard_state.dart';


class  ErrorScreen extends StatefulWidget {
  final QuaDashboardState state;
  final VoidCallback retryButtonClicked;
  const ErrorScreen({super.key, required this.state, required this.retryButtonClicked});

  @override
  State< ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State< ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.state is QuaDashboardError) {

      String errorMessage = "Something went wrong";
      if(widget.state.toString().contains("profile not found")){
        errorMessage ="We couldn’t find a profile linked to this email. Please verify and retry.";
      }


      Widget buildLoginButton(){
        if(widget.state.toString().contains("profile not found")){
          return TextButton(
              onPressed: () async{
                bool isCleared = await ClientLoginManager().clearClientProfile();
                if (isCleared) {
                  if(!mounted) return;
                  context.go(AppRoutes.signInOptions);
                } else {
                  FloatingMessage.show(context, message: "Failed", type:FloatingMessageType.error );
                }
              },
              child: Text("Got to login screen",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFDA5747),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.30,
                ),
              )
          );
        }
       return SizedBox.shrink();
      }

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Error !",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      height: 0.75,
                      letterSpacing: -0.56,
                    ),
                  ),
                  SizedBox(height: 24,),
                  Text(errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.60,
                    ),
                  ),
                  SizedBox(height: 64,),
                  ElevatedButton(
                    onPressed: widget.retryButtonClicked,
                    style:ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF308BF9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ) ,
                    child: Text("Try again",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.10,
                        letterSpacing: 0.30,
                      ),
                    ),
                  ),
                  SizedBox(height: 24,),
                  buildLoginButton(),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}


