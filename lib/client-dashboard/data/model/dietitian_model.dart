class DietitianModel {
  final int id;
  final String dietitianId;
  final String name;
  final String phoneNo;
  final String email;
  final String location;
  final String logo;
  final String dttm;
  final String password;

  DietitianModel({
    required this.id,
    required this.dietitianId,
    required this.name,
    required this.phoneNo,
    required this.email,
    required this.location,
    required this.logo,
    required this.dttm,
    required this.password,
  });

  factory DietitianModel.fromJson(Map<String, dynamic> json) {
    return DietitianModel(
      id: int.parse(json['id'].toString()),
      dietitianId: json['dietician_id'] ?? '',
      name: json['name'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] ?? '',
      logo: json['logo'] ?? '', // expected base64 string from API
      dttm: json['dttm'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dietician_id': dietitianId,
      'name': name,
      'phone_no': phoneNo,
      'email': email,
      'location': location,
      'logo': logo,
      'dttm': dttm,
      'password': password,
    };
  }
}
