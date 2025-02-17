import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/api/api_provider.dart';
import 'package:task_manager_app/util/app_constants.dart';

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

  Future<ApiResponse> verifyOtp(Map signUpBody) async {
    try {
      ApiResponse response = await apiClient
          .postData(AppConstants.verifyOtpApi, signUpBody, handleError: false);
      if (response.statusCode == 200) {
        if (response.body['token'] != null) {}
        return response;
      }
      throw Exception(response.body['message'] ?? "OTP verification failed");
    } catch (e) {
      throw Exception("Error during OTP verification: $e");
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

  Future<void> logout() async {
    try {
      await sharedPreferences.remove(AppConstants.token);
    } catch (e) {
      throw Exception("Error during logout: $e");
    }
  }
}
