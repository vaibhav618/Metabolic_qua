class ClientProfileModel {
  final int id;
  // Note: API key in JSON uses 'dietician_id' (with a 'c')
  final String dietitianId;
  final String profileId;
  final String phoneNo;
  final String email;
  final String profileName;
  final String profileImage;
  final String age;
  final String gender;
  final String height;
  final String weight;
  final String region;
  final String location;
  final String dttm;
  final int isNotificationEnabled;
  // Renamed to avoid collision with the boolean getter
  final int isDietitianLinkedInt;

  ClientProfileModel({
    required this.id,
    required this.dietitianId,
    required this.profileId,
    required this.phoneNo,
    required this.email,
    required this.profileName,
    required this.profileImage,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.region,
    required this.location,
    required this.dttm,
    required this.isNotificationEnabled,
    // Using the new field name
    required this.isDietitianLinkedInt,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: json['id'] as int,
      // API key used here
      dietitianId: json['dietician_id'] as String,
      profileId: json['profile_id'] as String,
      phoneNo: json['phone_no'] as String,
      email: json['email'] as String,
      profileName: json['profile_name'] as String,
      profileImage: json['profile_image'] as String,
      age: json['age'] as String,
      gender: json['gender'] as String,
      height: json['height'] as String,
      weight: json['weight'] as String,
      region: json['region'] as String,
      location: json['location'] as String,
      dttm: json['dttm'] as String,
      isNotificationEnabled: json['is_notification_enabled'] as int,
      // Using the new field name
      isDietitianLinkedInt: json['is_dietitian_linked'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // API key used here
      'dietician_id': dietitianId,
      'profile_id': profileId,
      'phone_no': phoneNo,
      'email': email,
      'profile_name': profileName,
      'profile_image': profileImage,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'region': region,
      'location': location,
      'dttm': dttm,
      'is_notification_enabled': isNotificationEnabled,
      'is_dietitian_linked': isDietitianLinkedInt,
    };
  }

  // Add copyWith method for immutability
  ClientProfileModel copyWith({
    int? id,
    String? dietitianId,
    String? profileId,
    String? phoneNo,
    String? email,
    String? profileName,
    String? profileImage,
    String? age,
    String? gender,
    String? height,
    String? weight,
    String? region,
    String? location,
    String? dttm,
    int? isNotificationEnabled,
    int? isDietitianLinkedInt, // Updated parameter name
  }) {
    return ClientProfileModel(
      id: id ?? this.id,
      dietitianId: dietitianId ?? this.dietitianId,
      profileId: profileId ?? this.profileId,
      phoneNo: phoneNo ?? this.phoneNo,
      email: email ?? this.email,
      profileName: profileName ?? this.profileName,
      profileImage: profileImage ?? this.profileImage,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      region: region ?? this.region,
      location: location ?? this.location,
      dttm: dttm ?? this.dttm,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      // Updated field/parameter name
      isDietitianLinkedInt: isDietitianLinkedInt ?? this.isDietitianLinkedInt,
    );
  }

  // Helper method to convert to boolean for easier UI handling
  bool get isNotificationsEnabledBool => isNotificationEnabled == 1;
  // Corrected name to avoid field collision
  bool get isDietitianLinked => isDietitianLinkedInt == 1;

  // Helper method to convert from boolean to int for API
  static int boolToInt(bool value) => value ? 1 : 0;
}