import 'package:equatable/equatable.dart';

class DietitianResultState extends Equatable {
  final String selectedTab;

  const DietitianResultState({this.selectedTab = 'Gut'});

  DietitianResultState copyWith({String? selectedTab}) {
    return DietitianResultState(selectedTab: selectedTab ?? this.selectedTab);
  }

  @override
  List<Object?> get props => [selectedTab];
}
