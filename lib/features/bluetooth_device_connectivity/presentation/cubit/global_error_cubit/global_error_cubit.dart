import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalErrorState {
  final String? message;
  const GlobalErrorState({this.message});
}

class GlobalErrorCubit extends Cubit<GlobalErrorState> {
  GlobalErrorCubit() : super(const GlobalErrorState());

  void show(String message) => emit(GlobalErrorState(message: message));
  void clear() => emit(const GlobalErrorState());
}

final GlobalErrorCubit globalErrorCubit = GlobalErrorCubit();
