class VerifyOtpModel {
  final String otp;
  final bool user;
  final String? token;

  VerifyOtpModel({required this.otp, required this.user, this.token});

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpModel(
      otp: json['otp'],
      user: json['user'],
      token: json['token'] != null ? json['token']['access'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'user': user,
      'token': token != null ? {'access': token} : null,
    };
  }
}
