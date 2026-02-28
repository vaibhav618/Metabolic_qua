// lib/features/retake_test/presentation/widgets/retake_test_options.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/retake_test_cubit.dart';
import '../../bloc/retake_test_state.dart';
import '../widgets/screen_radio_button.dart';

class RetakeTestOptions extends StatelessWidget {
  final TextEditingController detailsController;

  const RetakeTestOptions({
    super.key,
    required this.detailsController,
  });

  bool _shouldShowInput(String? selectedReason) {
    return selectedReason == "not_satisfied" || selectedReason == "other";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetakeTestCubit, RetakeTestState>(
      buildWhen: (p, n) =>
      p.selectedReason != n.selectedReason || p.details != n.details,
      builder: (context, state) {
        final cubit = context.read<RetakeTestCubit>();

        final showInput = _shouldShowInput(state.selectedReason);

        if (!showInput && detailsController.text.isNotEmpty) {
          detailsController.clear();
        }

        if (showInput && detailsController.text != state.details) {
          detailsController.value = TextEditingValue(
            text: state.details,
            selection: TextSelection.collapsed(offset: state.details.length),
          );
        }

        return Column(
          children: [
            ScreenRadioButton(
              label: "Just curious",
              value: "curious",
              selectedValue: state.selectedReason,
              showInput: false,
              controller: detailsController,
              onSelected: (v) {
                cubit.selectReason(v);
                detailsController.clear();
              },
              onTextChanged: () {},
            ),
            ScreenRadioButton(
              label: "Not satisfied with the first test",
              value: "not_satisfied",
              selectedValue: state.selectedReason,
              showInput: true,
              controller: detailsController,
              onSelected: cubit.selectReason,
              onTextChanged: () => cubit.updateDetails(detailsController.text),
            ),
            ScreenRadioButton(
              label: "Other",
              value: "other",
              selectedValue: state.selectedReason,
              showInput: true,
              controller: detailsController,
              onSelected: cubit.selectReason,
              onTextChanged: () => cubit.updateDetails(detailsController.text),
            ),
          ],
        );
      },
    );
  }
}
