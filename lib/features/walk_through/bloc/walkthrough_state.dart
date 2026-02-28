import 'package:equatable/equatable.dart';

class WalkthroughState extends Equatable {
  final int currentPage;    // 0, 1, 2
  final bool isCompleted;   // true when user finishes / skips

  const WalkthroughState({
    required this.currentPage,
    required this.isCompleted,
  });

  factory WalkthroughState.initial() {
    return const WalkthroughState(
      currentPage: 0,
      isCompleted: false,
    );
  }

  WalkthroughState copyWith({
    int? currentPage,
    bool? isCompleted,
  }) {
    return WalkthroughState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [currentPage, isCompleted];
}
