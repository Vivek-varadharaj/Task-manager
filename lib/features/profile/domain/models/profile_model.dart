class ProfileModel {
  final String name;
  final String phoneNumber;

  ProfileModel({required this.name, required this.phoneNumber});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_number': phoneNumber,
    };
  }
}
