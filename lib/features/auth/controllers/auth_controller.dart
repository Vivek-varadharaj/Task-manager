import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_manager_app/common/models/response_model.dart';

import 'package:task_manager_app/features/auth/domain/models/login_response_model.dart';
import 'package:task_manager_app/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository authRepository;
  AuthController({required this.authRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LoginResponseModel? _loginResponseModel;
  LoginResponseModel? get loginResponseModel => _loginResponseModel;

  bool _obsecureText = true;
  bool get obsecureText => _obsecureText;

  Future<ResponseModel> loginUsingPassword(
      {required Map<String, dynamic> loginRequestModel}) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response =
          await authRepository.loginUsingPassword(loginRequestModel);
      if (response.statusCode == 200) {
        _loginResponseModel = LoginResponseModel.fromJson(response.body);
        authRepository.saveUserToken(_loginResponseModel?.accessToken ?? "");
        authRepository.saveUser(response.body);

        return ResponseModel(response.statusCode == 200, "Login successful");
      }

      return ResponseModel(
          response.statusCode == 200, response.body['message']);
    } catch (e) {
      return ResponseModel(false, e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? getIsUserLoggedIn() {
    try {
      return authRepository.isUserLoggedIn();
    } catch (e) {
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      return await authRepository.logout();
    } catch (e) {
      return false;
    }
  }

  Future<void> saveUserToken(String token) async {
    try {
      await authRepository.saveUserToken(token);
    } catch (e) {}
  }

  Future<void> toggleObsecureText() async {
    try {
      _obsecureText = !_obsecureText;
      notifyListeners();
    } catch (e) {}
  }
}
