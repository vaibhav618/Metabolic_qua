import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/walkthrough_bloc.dart';
import '../../bloc/walkthrough_event.dart';

class WalkThroughBottomNav extends StatelessWidget {
  final WalkthroughBloc bloc;
  final int currentPage;

  const WalkThroughBottomNav({
    super.key,
    required this.bloc,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentPage) {
      case 0:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildPrimaryButton(
                label: "Next",
                onPressed: () => bloc.add(const NextPressed()),
              ),
            ],
          ),
        );

      case 1:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => bloc.add(const PreviousPressed()),
                icon: const Icon(Icons.keyboard_arrow_left_outlined),
              ),
              _buildPrimaryButton(
                label: "Next",
                onPressed: () => bloc.add(const NextPressed()),
              ),
            ],
          ),
        );

      default:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => bloc.add(const PreviousPressed()),
                icon: const Icon(Icons.keyboard_arrow_left_outlined),
              ),
              _buildPrimaryButton(
                label: "Get started",
                onPressed: () => bloc.add(const SkipPressed()),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2555),
        ),
        backgroundColor: const Color(0xFF308BF9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      child: Row(
        spacing: 20,
        children: [
          const Icon(
            Icons.keyboard_arrow_right_outlined,
            color: Colors.transparent,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.10,
              letterSpacing: 0.30,
            ),
          ),
          const Icon(Icons.keyboard_arrow_right_outlined),
        ],
      ),
    );
  }
}
