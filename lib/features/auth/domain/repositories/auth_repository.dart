import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/api/api_provider.dart';

import 'package:task_manager_app/util/app_constants.dart';
import 'package:task_manager_app/util/app_texts.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepository({required this.sharedPreferences, required this.apiClient});

  Future<ApiResponse> loginUsingPassword(Map loginBody) async {
    try {
      ApiResponse response = await apiClient.postData(
          AppConstants.loginUsingPasswordApi, loginBody,
          handleError: false);
      if (response.statusCode == 200) {
        if (response.body['token'] != null) {
          await saveUserToken(response.body['token']['access']);
        }

        return response;
      }
      throw Exception(response.body['message'] ?? "Registration failed");
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> saveUserToken(String token) async {
    try {
      apiClient.token = token;
      apiClient.updateHeader(token);
      return await sharedPreferences.setString(AppConstants.token, token);
    } catch (e) {
      throw Exception("Error saving user token: $e");
    }
  }

  String? isUserLoggedIn() {
    try {
      return sharedPreferences.getString(AppConstants.token);
    } catch (e) {
      throw Exception("Error checking login status: $e");
    }
  }

  Future<bool> logout() async {
    try {
      await sharedPreferences.remove(AppConstants.token);
      await sharedPreferences.remove(AppTexts.userData);
      return true;
    } catch (e) {
      throw Exception("Error during logout: $e");
    }
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    await sharedPreferences.setString(AppTexts.userData, jsonEncode(userData));
  }
}
