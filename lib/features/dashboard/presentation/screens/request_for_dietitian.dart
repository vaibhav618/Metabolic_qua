import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import '../../../../client-dashboard/presentation/widgets/dashboard_appbar.dart';
import '../../../../common/bottom_sheets/respyr_bottom_sheet.dart';
import '../../../bluetooth_device_connectivity/data/model/generating_result_model.dart';
import '../../../gifting/dashboard/presentation/widgets/test_result_history.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_event.dart';
import '../../bloc/dashboard_state.dart';

class RequestForDietitian extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final GeneratingResultModel? todayResult;

  const RequestForDietitian({
    super.key,
    required this.clientProfileModel,
    this.todayResult,
  });

  @override
  State<RequestForDietitian> createState() => _RequestForDietitianState();
}

class _RequestForDietitianState extends State<RequestForDietitian> {
  void showDietitianLinkStatus({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return AppBottomSheet(
          onCloseSheet: () {
            Navigator.pop(context);

          }, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset("assets/images/icons/ic_clock_3d.png", cacheWidth: 100, cacheHeight: 100,),
              SizedBox(height: 22,),
              Text("Request already sent!",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              SizedBox(height: 15,),
              Text("You have sent request on 12th jul 2024, 12:04pm.",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                  height: 1
                ),
              ),
              SizedBox(height: 24,),
              Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF5F7FA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(text: TextSpan(
                      children: [
                        TextSpan(text:  "Status : ",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.26,
                          letterSpacing: -0.24,
                        )
                        ),
                        TextSpan(text:  "Approval Pending",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.26,
                              letterSpacing: -0.24,
                            )
                        )
                      ]
                    )),
                    TextButton(
                        onPressed: (){},
                        child: Text("Resent request",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF308BF9),
                            decorationColor: Color(0xFF308BF9),     // 👈 underline color
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                            height: 1.26,
                            letterSpacing: -0.24,
                          ),
                        )
                    )
                  ],
                ),
              ),
              SizedBox(height: 28,),
            ],
                    ),
          ),

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) {
        if (current is! DashboardReady) return false;

        final status = current.dietitianLinkStatus;
        final isChecking = current.isCheckingLinkStatus;

        return !isChecking &&
            status != null &&
            status.toUpperCase() == "PENDING";
      },
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDietitianLinkStatus(context: context);
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: const Color(0xFFD3E5FF),
            elevation: 0,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🔹 Main top section
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFD3E5FF),
                      ],
                      stops: [0.0, 1.0],
                    ),
                  ),
                  padding:
                  const EdgeInsets.only(top: 25, left: 10, right: 10),
                  child: Column(
                    children: [
                      DashboardAppbar(
                        clientProfileModel: widget.clientProfileModel,
                        isDefaultColor: true, activeData: [], completedData: [], canceledData: [],
                      ),
                      const SizedBox(height: 80),
                      Image.asset(
                        "assets/images/icons/ic_dietitian.png",
                        width: 172,
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 302),
                        child: Text(
                          "Connect with consultant",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -2.04,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 216),
                        child: Text(
                          "Send request to connect with your consultant",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // 🔥 Button with BlocBuilder (reacts to status + loading)
                      BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, state) {
                          bool isChecking = false;
                          String? status;

                          if (state is DashboardReady) {
                            isChecking = state.isCheckingLinkStatus;
                            status = state.dietitianLinkStatus;
                          }

                          String label;
                          if (status != null &&
                              status.toUpperCase() == "PENDING") {
                            label = "Request Pending";
                          } else if (status != null &&
                              status.toUpperCase() == "ACCEPTED") {
                            label = "Linked with Consultant";
                          } else if (status != null &&
                              status.toUpperCase() == "REJECTED") {
                            label = "Request Rejected – Try again";
                          } else {
                            label = "Connect Now";
                          }

                          return GestureDetector(
                            onTap: isChecking
                                ? null
                                : () {
                              context.read<DashboardBloc>().add(
                                CheckDietitianLinkStatus(
                                  widget.clientProfileModel.profileId
                                      .toString(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 9,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFF308BF9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isChecking) ...[
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    label,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.10,
                                      letterSpacing: -0.24,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_right_outlined,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 54),
                    ],
                  ),
                ),

                const SizedBox(height: 31),
                TestResultHistory(
                  result: widget.todayResult,
                  clientProfileModel: widget.clientProfileModel,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
