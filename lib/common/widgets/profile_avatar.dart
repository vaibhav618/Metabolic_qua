import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final bool allowTap;

  const ProfileAvatar({super.key, this.radius = 50, this.allowTap = true});

  Future<void> _openFullScreen(BuildContext context, String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;
        if (context.mounted) {
          context.push(AppRoutes.fullScreenImageView, extra: imageBytes);
        }
      } else {
        debugPrint('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profileImage = state.profileImagePath;
        final dietitianImageUrl = state.dietitianImageUrl;

        Widget avatarContent;

        if (dietitianImageUrl.isNotEmpty) {
          // ✅ Priority 1: API image
          avatarContent = GestureDetector(
            onTap:
                allowTap
                    ? () => _openFullScreen(context, dietitianImageUrl)
                    : null,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: const Color(0xFFF0F0F0),
              backgroundImage: NetworkImage(dietitianImageUrl),
            ),
          );
        } else if (profileImage != null) {
          // ✅ Priority 2: Local memory image
          // avatarContent = GestureDetector(
          //   onTap:
          //       allowTap
          //           ? () {
          //             context.push(
          //               AppRoutes.fullScreenImageView,
          //               extra: profileImage,
          //             );
          //           }
          //           : null,
          //   child: CircleAvatar(
          //     radius: radius,
          //     backgroundColor: const Color(0xFFF0F0F0),
          //     backgroundImage: MemoryImage(profileImage),
          //   ),
          // );

          return Container();
        } else {
          // ✅ Priority 3: Fallback SVG
          avatarContent = CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFFF0F0F0),
            child: SvgPicture.asset(
              "assets/images/common/profile_logo.svg",
              height: radius,
            ),
          );
        }

        return Center(child: avatarContent);
      },
    );
  }
}
