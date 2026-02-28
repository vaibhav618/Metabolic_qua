import 'package:flutter/material.dart';

class ProfileProgressBar extends StatelessWidget {
  final int stepCompleted;
  final int totalStep;

  const ProfileProgressBar({
    super.key,
    required this.stepCompleted,
    this.totalStep = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalStep, (index) {
          final isFilled = index < stepCompleted;
          return Flexible(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(right: index < totalStep - 1 ? 5.0 : 0),
              decoration: BoxDecoration(
                color: isFilled ? Colors.black : Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        }),
      ),
    );
  }
}
