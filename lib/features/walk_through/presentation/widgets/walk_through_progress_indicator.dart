import 'package:flutter/material.dart';

Widget buildWalkThoughProgressIndicator(int currentPage) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 5,
      children: List.generate(3, (index) {
        final isActive = index == currentPage;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 5,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF252525) : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    ),
  );
}