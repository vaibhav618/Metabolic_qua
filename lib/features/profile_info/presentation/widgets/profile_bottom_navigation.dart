import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';

class ProfileBottomNavigation extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String? nextLabel; // optional label for the next button

  const ProfileBottomNavigation({
    super.key,
    this.onNext,
    this.onBack,
    this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom + rh(context: context, px: 5);

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset > rh(context: context, px: 5)
            ? bottomInset
            : rh(context: context, px: 30),
        left: rh(context: context, px: 26),
        right: rh(context: context, px: 26),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(
                rh(context: context, px: 16),
              ),
            ),
            icon: Icon(
              Icons.chevron_left_outlined,
              size: rh(context: context, px: 24),
            ),
          ),
          IconButton(
            onPressed: onNext,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF308BF9),
              padding: EdgeInsets.all(
                rh(context: context, px: 16),
              ),
            ),
            icon: Icon(
              Icons.chevron_right_outlined,
              size: rh(context: context, px: 24),
            ),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
