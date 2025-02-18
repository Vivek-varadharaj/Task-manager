import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/api/api_provider.dart';
import 'package:task_manager_app/features/auth/domain/models/login_response_model.dart';
import 'package:task_manager_app/util/app_texts.dart';

class ProfileRepository {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  ProfileRepository({
    required this.apiClient,
    required this.sharedPreferences,
  });

  Future<LoginResponseModel?> getUser() async {
    String? userData = sharedPreferences.getString(AppTexts.userData);
    if (userData != null) {
      return LoginResponseModel.fromJson(jsonDecode(userData));
    }
    return null;
  }
}
