import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/result_screen/data/repository/result_repository.dart';
import 'package:respyr_dietitian/features/result_screen/presentation/cubit/result_state.dart';

class ResultCubit extends Cubit<ResultState> {
  final ResultRepository repository;

  ResultCubit(this.repository) : super(ResultInitial());

  Future<void> fetchResultData() async {
    emit(ResultLoading());

    try {
      final result = await repository.fetchResults();
      emit(ResultLoaded(result));
    } catch (e) {
      emit(ResultError(e.toString()));
    }
  }
}
