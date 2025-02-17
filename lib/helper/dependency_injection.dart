import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/api/api_provider.dart';
import 'package:task_manager_app/features/auth/controllers/auth_controller.dart';
import 'package:task_manager_app/features/auth/domain/repositories/auth_repository.dart';

import 'package:task_manager_app/util/app_constants.dart';

Future<List<ChangeNotifierProvider>> initProviders() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  final apiClient = ApiClient(
    appBaseUrl: AppConstants.appBaseUrl,
    sharedPreferences: sharedPreferences,
  );

  final authRepository = AuthRepository(
    sharedPreferences: sharedPreferences,
    apiClient: apiClient,
  );

  return [
    ChangeNotifierProvider<AuthController>(
      create: (context) => AuthController(authRepository: authRepository),
    ),
    // Add more providers if needed
  ];
}
