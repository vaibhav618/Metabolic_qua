import 'package:equatable/equatable.dart';

enum BluetoothGateDialogType { none, androidTurnOn, iosWait }

class BluetoothGateState extends Equatable {
  final bool isChecking;
  final BluetoothGateDialogType dialog;
  final bool shouldNavigateNext;

  const BluetoothGateState({
    this.isChecking = false,
    this.dialog = BluetoothGateDialogType.none,
    this.shouldNavigateNext = false,
  });

  BluetoothGateState copyWith({
    bool? isChecking,
    BluetoothGateDialogType? dialog,
    bool? shouldNavigateNext,
  }) {
    return BluetoothGateState(
      isChecking: isChecking ?? this.isChecking,
      dialog: dialog ?? this.dialog,
      shouldNavigateNext: shouldNavigateNext ?? this.shouldNavigateNext,
    );
  }

  @override
  List<Object?> get props => [isChecking, dialog, shouldNavigateNext];
}
