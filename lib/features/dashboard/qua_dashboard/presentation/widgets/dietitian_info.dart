import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:respyr_dietitian/core/size/get_height.dart';
import '../../../../profile_info/data/model/dietician_detail_model.dart';

class DietitianInfo extends StatelessWidget {
  final DietitianDetailModel? dietitianDetailModel;
  const DietitianInfo({super.key, this.dietitianDetailModel});

  @override
  Widget build(BuildContext context) {
    final model = dietitianDetailModel;

    final String consultantName =
    (model?.dietitianId?.trim().isNotEmpty ?? false) ? model!.dietitianId!.trim() : "-";

    final String clinicName =
    (model?.clinicName?.trim().isNotEmpty ?? false) ? model!.clinicName!.trim() : "-";

    final String city =
    (model?.location?.trim().isNotEmpty ?? false) ? model!.location!.trim() : "";

    final String clinicLine = city.isNotEmpty ? "@ $clinicName, $city" : "@ $clinicName";

    final String? logoUrl =
    (model?.logoUrl?.trim().isNotEmpty ?? false) ? model!.logoUrl!.trim() : null;

    final String name = (model?.name.trim().isNotEmpty ?? false) ? model!.name.trim() : "-";
    final String location =
    (model?.location.trim().isNotEmpty ?? false) ? model!.location.trim() : "-";
    final String email = (model?.email.trim().isNotEmpty ?? false) ? model!.email.trim() : "-";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 10)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          0,
          rh(context: context, px: 30),
          0,
          rh(context: context, px: 54),
        ),
        decoration: ShapeDecoration(
          gradient: const RadialGradient(
            center: Alignment(0.50, 0.50),
            radius: 0.50,
            colors: [Color(0xFFF5F7FA), Color(0xFFEDF5FF)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rh(context: context, px: 10)),
          ),
        ),
        child: Column(
          children: [
            Text(
              "Your Consultant",
              style: GoogleFonts.poppins(
                color: const Color(0xFF308BF9),
                fontSize: rh(context: context, px: 18),
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: -0.72,
              ),
            ),
            SizedBox(height: rh(context: context, px: 30)),
            SizedBox(
              height: rh(context: context, px: 70),
              width: rh(context: context, px: 70),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(rh(context: context, px: 12)),
                child: _ConsultantLogo(logoUrl: logoUrl),
              ),
            ),
            SizedBox(height: rh(context: context, px: 26)),
            Text(
              name,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: rh(context: context, px: 6)),
            _MetaRow(
              location: location,
              email: email,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultantLogo extends StatelessWidget {
  final String? logoUrl;
  const _ConsultantLogo({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final url = logoUrl;

    if (url == null) {
      return SvgPicture.asset(
        "assets/images/icons/default1.svg",
        fit: BoxFit.contain,
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return SvgPicture.asset(
          "assets/images/icons/default1.svg",
          fit: BoxFit.contain,
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String location;
  final String email;

  const _MetaRow({
    required this.location,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          location,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: rh(context: context, px: 12),
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
          ),
        ),
        SizedBox(width: rh(context: context, px: 10)),
        Text(
          email,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: rh(context: context, px: 12),
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
          ),
        ),
      ],
    );
  }
}
