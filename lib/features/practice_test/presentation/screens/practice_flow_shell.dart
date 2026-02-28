import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import '../../practice_test_home/bloc/practice_flow_bloc.dart';

class PracticeFlowShell extends StatelessWidget {
  final Widget child;
  const PracticeFlowShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => PracticeFlowBloc(repo: ctx.read<BluetoothRepository>()),
      child: child,
    );
  }
}