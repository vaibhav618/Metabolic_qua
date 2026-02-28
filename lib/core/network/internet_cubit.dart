import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetCubit extends Cubit<bool> {
  InternetCubit() : super(true);

  StreamSubscription<List<ConnectivityResult>>? _sub;

  void startListening() {
    // emit initial
    _checkInitial();

    // listen changes (latest connectivity_plus emits List<ConnectivityResult>)
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final hasInternet = results.isNotEmpty &&
          results.every((r) => r != ConnectivityResult.none);
      emit(hasInternet);
    });
  }

  Future<void> _checkInitial() async {
    final results = await Connectivity().checkConnectivity();
    final hasInternet =
        results.isNotEmpty && results.every((r) => r != ConnectivityResult.none);
    emit(hasInternet);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
