
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respyr_dietitian/features/retake_test/bloc/retake_test_cubit.dart';
import 'package:respyr_dietitian/features/retake_test/bloc/retake_test_state.dart';


void main() {
  group('RetakeTestCubit', () {
    blocTest<RetakeTestCubit, RetakeTestState>(
      'initial state is empty',
      build: () => RetakeTestCubit(),
      expect: () => <RetakeTestState>[],
      verify: (cubit) {
        expect(cubit.state.selectedReason, isNull);
        expect(cubit.state.details, '');
        expect(cubit.state.isButtonEnabled, false);
      },
    );

    blocTest<RetakeTestCubit, RetakeTestState>(
      'select curious enables button',
      build: () => RetakeTestCubit(),
      act: (cubit) => cubit.selectReason('curious'),
      expect: () => const <RetakeTestState>[
        RetakeTestState(selectedReason: 'curious', details: ''),
      ],
      verify: (cubit) {
        expect(cubit.state.isButtonEnabled, true);
      },
    );

    blocTest<RetakeTestCubit, RetakeTestState>(
      'select other requires details',
      build: () => RetakeTestCubit(),
      act: (cubit) => cubit.selectReason('other'),
      expect: () => const <RetakeTestState>[
        RetakeTestState(selectedReason: 'other', details: ''),
      ],
      verify: (cubit) {
        expect(cubit.state.isButtonEnabled, false);
      },
    );

    blocTest<RetakeTestCubit, RetakeTestState>(
      'typing details enables button for other',
      build: () => RetakeTestCubit(),
      act: (cubit) {
        cubit.selectReason('other');
        cubit.updateDetails('device disconnected');
      },
      expect: () => const <RetakeTestState>[
        RetakeTestState(selectedReason: 'other', details: ''),
        RetakeTestState(selectedReason: 'other', details: 'device disconnected'),
      ],
      verify: (cubit) {
        expect(cubit.state.isButtonEnabled, true);
      },
    );
  });
}
