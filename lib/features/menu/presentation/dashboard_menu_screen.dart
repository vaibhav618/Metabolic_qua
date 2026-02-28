import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/extras/logout.dart';
import '../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../common/widgets/client_profile_avatar.dart';
import '../../client_profile/presentation/pages/client_profile.dart';
import '../../diet_plan/data/diet_plan_model.dart';
import '../../diet_plan/presentation/pages/diet_plan_screen.dart';
import '../../webview/presentation/screens/webview_screen.dart';
import '../../webview/utils/urls.dart';

class DashboardMenuScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const DashboardMenuScreen({super.key, required this.clientProfileModel});

  @override
  State<DashboardMenuScreen> createState() => _DashboardMenuScreenState();
}

class _DashboardMenuScreenState extends State<DashboardMenuScreen> {

  bool isLoggingOut=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Row(
          children: [
            Text("Profile details",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.30,
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(height: 10,),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientProfileScreen(clientProfileModel: widget.clientProfileModel,),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10 ),
                  child: Container(
                    width: double.infinity,

                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        ClientProfileAvatar(profileImageUrl: widget.clientProfileModel.profileImage,height: 30,),
                        SizedBox(width: 20,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.clientProfileModel.profileName,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  letterSpacing: -0.72,
                                ),
                              ),
                              SizedBox(height: 5,),
                              Text(widget.clientProfileModel.email,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    letterSpacing: -0.24,
                                  )
                              )
                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClientProfileScreen(clientProfileModel: widget.clientProfileModel,),
                                ),
                              );
                            },
                            style:ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero
                            ) ,
                            child: Icon(Icons.keyboard_arrow_right_outlined)
                        )
                      ],
                    ),
                  ),

                ),
              ),

              SizedBox(height: 20,),
              Container(width: double.infinity,height: 1,color: Color(0xFFC7C6CE),),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: GestureDetector(
                  onTap: (){
                    final weekFuture = DietApi.fetchWeekFromServer(
                      Uri.parse('https://humorstech.com/dietitian/api/app/get_diet.php'),
                      form: {'login_id':'USR123','profile_id':'PROF456'},
                    );

                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => DietWeekPage(futureWeek: weekFuture,),
                    //   ),
                    // );
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/images/icons/ic_account_center.svg"),
                      SizedBox(width: 10,),
                      Text("Diet plan",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: GestureDetector(
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/images/icons/ic_account_center.svg"),
                      SizedBox(width: 10,),
                      Text("Account Setting",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: GestureDetector(
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/images/icons/ic_help.svg"),
                      SizedBox(width: 10,),
                      Text("Help Center",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WebViewScreen(url: WebViewUrls.privacyPolicy),
                      ),
                    );

                  },
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/images/icons/ic_help.svg"),
                      SizedBox(width: 10,),
                      Text("Privacy policy",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: GestureDetector(
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/images/icons/ic_help.svg"),
                      SizedBox(width: 10,),
                      Text("Terms & Conditions",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Spacer(),
              Container(width: double.infinity,height: 1,color: Color(0xFFC7C6CE),),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: InkWell(
                  onTap: (){
                    Logout().show(context,isLoggingOut: (bool isLoggingOut) {

                      setState(() {
                        isLoggingOut=this.isLoggingOut;
                      });

                    });
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/images/icons/ic_logout.svg"),
                      SizedBox(width: 10,),
                      Text(isLoggingOut ? "Logging out " : "Logout",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFEA5455),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.30,
                        ),
                      )
                    ],
                  ),
                ),
              ),





              //
              // ElevatedButton(
              //   onPressed: () {
              //     final api  = TestDataApi();
              //     final repo = TestDataRepository(api: api);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => BlocProvider(
              //           create: (_) => TestDataBloc(repo: repo),
              //           child: TestDataPage(
              //             initialProfileId: widget.clientProfileModel.profileId, initialDate: DateTime.parse(widget.clientProfileModel.dttm), startDate: DateTime.now(),
              //           ),
              //         ),
              //       ),
              //     );
              //   },
              //   child: const Text("Test history"),
              // ),
              //
              // ElevatedButton(
              //   onPressed: () {
              //
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => Dashboard(clientProfileModel: widget.clientProfileModel,
              //
              //         ),
              //       ),
              //     );
              //   },
              //   child: const Text("Gifting Dashboard"),
              // )



            ],
          ),
        ),
      ),
    );
  }
}
