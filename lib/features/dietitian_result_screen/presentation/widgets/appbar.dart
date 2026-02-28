import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../../core/size/get_height.dart';
import '../../../bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';

Widget resultScreenAppbar(BuildContext context, {
  required ClientProfileModel clientProfile,
  required TestResultResponse testResultResponse,
  required VoidCallback navigateToDashboardClicked}
    ) {



  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '';

    try {
      final date = DateTime.parse(dateTime).toLocal();
      return DateFormat('d MMM yyyy, h:mma').format(date);
    } catch (_) {
      return dateTime ?? '';
    }
  }


  return SliverAppBar(
    pinned: true,
    automaticallyImplyLeading: false,
    backgroundColor: const Color(0xFF308BF9),
    expandedHeight: rh(context: context, px: 50),
    flexibleSpace: FlexibleSpaceBar(
      titlePadding: EdgeInsets.zero,
      title: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: rh(context: context, px: 5),
                children: [
                  Text(
                    clientProfile.profileName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: rh(context: context, px: 18),
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      letterSpacing: rh(context: context, px: -0.72),
                    ),
                  ),
                  Text(
                    formatDateTime(testResultResponse.dateTime),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: rh(context: context, px: 10),
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                      letterSpacing: rh(context: context, px: -0.2),
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: navigateToDashboardClicked,
                icon: SvgPicture.asset(
                  "assets/images/common/closeicon.svg",
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}