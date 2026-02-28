import 'package:flutter/material.dart';

import '../../../../core/size/get_height.dart' show rh;
import '../theme/test_conditions_tokens.dart';
import 'test_condition_item.dart';

class TestConditionsSheet extends StatelessWidget {
  const TestConditionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: rh(
        context: context,
        px: TestConditionsTokens.sheetHeight,
      ),
      decoration: ShapeDecoration(
        color: TestConditionsTokens.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              rh(
                context: context,
                px: TestConditionsTokens.sheetTopRadius,
              ),
            ),
            topRight: Radius.circular(
              rh(
                context: context,
                px: TestConditionsTokens.sheetTopRadius,
              ),
            ),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            rh(
              context: context,
              px: 17,
            ),
          ),
          child: const _ConditionsList(),
        ),
      ),
    );
  }
}

class _ConditionsList extends StatelessWidget {
  const _ConditionsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: rh(
        context: context,
        px: TestConditionsTokens.itemsColumnSpacing,
      ),
      children: const [
        TestConditionItem(
          iconAsset: "assets/images/icons/ic_condition_01.svg",
          title: "Fasting / Early Morning",
          body:
          "Take the test on an empty stomach, preferably early in the morning.",
        ),
        TestConditionItem(
          iconAsset: "assets/images/icons/ic_condition_02.svg",
          title: "Fresh Room",
          body:
          "Use in a well-ventilated, odor-free room.Avoid perfumes or room fresheners.",
        ),
        TestConditionItem(
          iconAsset: "assets/images/icons/ic_condition_03.svg",
          title: "No Airflow",
          body: "Keep the device away from fans, AC, or blowers.",
        ),
        TestConditionItem(
          iconAsset: "assets/images/icons/ic_condition_04.svg",
          title: "Sit & Relax",
          body: "Sit upright, stay relaxed, and breathe normally.",
        ),
        TestConditionItem(
          iconAsset: "assets/images/icons/ic_condition_05.svg",
          title: "Clean Hands",
          body: "Do not use alcohol-based sanitizers or fragrances.",
        ),
        TestConditionItem(
          iconAsset: "assets/images/icons/ic_condition_06.svg",
          title: "Keep Device Vent Clear",
          body:
          "Ensure the exhaust vent of the device at the bottom is not blocked.",
        ),
      ],
    );
  }
}
