import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_manager_app/common/models/response_model.dart';
import 'package:task_manager_app/features/auth/domain/models/login_request_model.dart';
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

  int _secondsRemaining = 60;
  Timer? _timer;
  int get secondsRemaining => _secondsRemaining;
  bool get isResendEnabled => _secondsRemaining == 0;

  void startTimer() {
    _timer?.cancel();
    _secondsRemaining = 60;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        notifyListeners();
      }
    });
  }

  Future<ResponseModel> loginUsingPassword(
      {required LoginRequestModel loginRequestModel}) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response =
          await authRepository.loginUsingPassword(loginRequestModel.toJson());
      if (response.statusCode == 200) {
        _loginResponseModel = LoginResponseModel.fromJson(response.body);
        authRepository.saveUserToken(_loginResponseModel?.accessToken ?? "");
        authRepository.saveUser(response.body);
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
