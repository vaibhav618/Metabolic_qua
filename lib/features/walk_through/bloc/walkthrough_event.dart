import 'package:equatable/equatable.dart';

abstract class WalkthroughEvent extends Equatable {
  const WalkthroughEvent();

  @override
  List<Object?> get props => [];
}

class NextPressed extends WalkthroughEvent {
  const NextPressed();
}

class PreviousPressed extends WalkthroughEvent {
  const PreviousPressed();
}

class SkipPressed extends WalkthroughEvent {
  const SkipPressed();
}
