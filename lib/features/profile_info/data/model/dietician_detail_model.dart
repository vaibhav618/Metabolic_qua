class DietitianDetailModel {
  final String id;
  final String dietitianId;
  final String name;
  final String phoneNo;
  final String email;
  final String location;
  final String clinicName;
  final String logoUrl;


  DietitianDetailModel({
    required this.id,
    required this.dietitianId,
    required this.name,
    required this.phoneNo,
    required this.email,
    required this.location,
    required this.clinicName,
    required this.logoUrl,
  });

  factory DietitianDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DietitianDetailModel(
      id: data['id'].toString(),
      dietitianId: data['dietician_id'],
      name: data['name'],
      phoneNo: data['phone_no'],
      email: data['email'],
      location: data['location'],
      logoUrl: data['logo_url'],
      clinicName: 'NA',

    );
  }
}