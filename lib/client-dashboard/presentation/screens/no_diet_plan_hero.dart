import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import '../../../features/chat_manger/data/bloc/chat_bloc.dart';
import '../../../features/chat_manger/data/repository/chat_repository.dart';
import '../../../features/chat_manger/presentation/screen/chat_screen.dart';
import '../../../features/diet_plan/presentation/pages/diet_plan_screen.dart';
import '../widgets/dashboard_appbar.dart';

class NoDietPlanHero extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel dietitianDetailModel;
  const NoDietPlanHero({super.key, required this.clientProfileModel, required this.dietitianDetailModel});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      decoration:  BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center, // 50% 50%
          radius: 1.0,              // 100%
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFD3E5FF)
          ],
          stops: [0.0, 1.0],
        ),
      ),
      padding: EdgeInsets.only(top: 25, left: 10, right: 10),
      child: Column(
        children: [
          DashboardAppbar(
            clientProfileModel: clientProfileModel,
            isDefaultColor: true,
            dietitianDetailModel: dietitianDetailModel, activeData: [], completedData: [], canceledData: [],
          ),
          SizedBox(height: 80,),
          Image.asset("assets/images/icons/ic_food_empty.png", width: 172,),
          SizedBox(height: 10,),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 302),
            child: Text("No diet plan available for today.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 34,
                fontWeight: FontWeight.w600,
                letterSpacing: -2.04,
              ),
            ),
          ),
          SizedBox(height: 15,),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 216),
            child: Text("Your consultant has’nt shared a meal plan yet.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w300,
                letterSpacing: -0.30,
              ),
            ),
          ),
          SizedBox(height: 48,),
          GestureDetector(
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) => ChatBloc(
                      repository: ChatRepository(
                        sender: ChatUser(
                          id: clientProfileModel.profileId,
                          firstName: clientProfileModel.profileName,
                        ),
                        receiver: ChatUser(
                          id: dietitianDetailModel.dietitianId,
                          firstName: dietitianDetailModel.name,
                        ),
                      ),
                    ),
                    child: ChatScreen(
                      dietitianModel: dietitianDetailModel,
                      clientProfileModel: clientProfileModel,
                      initialMessage: "Hello, I'm ready to begin my health journey. Could you please review and update my diet plan at your earliest convenience? I look forward to getting started.", // Add this if you have it
                    ),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: ShapeDecoration(
                color: const Color(0xFF308BF9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Text(
                        'Ask your consultant',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.24,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_right_outlined, color: Colors.white,size: 15,),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 54,),
        ],
      ),
    );
  }
}
