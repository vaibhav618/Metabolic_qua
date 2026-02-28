abstract class CheckClientEvent {}

class CheckClientProfileEvent extends CheckClientEvent {
  final String phoneNo;
  final String email;

  CheckClientProfileEvent({required this.phoneNo, required this.email});
}
