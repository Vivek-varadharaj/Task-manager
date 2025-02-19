import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/api/api_provider.dart';
import 'package:task_manager_app/features/auth/controllers/auth_controller.dart';
import 'package:task_manager_app/features/auth/domain/repositories/auth_repository.dart';

import 'package:task_manager_app/features/home/controllers/home_controller.dart';
import 'package:task_manager_app/features/home/domain/repositories/home_repository.dart';
import 'package:task_manager_app/features/internet_connectivity/controllers/controller.dart';
import 'package:task_manager_app/features/profile/controllers/profile_controller.dart';
import 'package:task_manager_app/features/profile/domain/repository/profile_repository.dart';
import 'package:task_manager_app/helper/database_helper.dart';

import 'package:task_manager_app/util/app_constants.dart';

Future<List<ChangeNotifierProvider>> initProviders() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  final dataBaseHelper = DatabaseHelper();

  final apiClient = ApiClient(
    appBaseUrl: AppConstants.appBaseUrl,
    sharedPreferences: sharedPreferences,
  );

  final authRepository = AuthRepository(
    sharedPreferences: sharedPreferences,
    apiClient: apiClient,
  );
  final homeRepository = HomeRepository(
    apiClient: apiClient,
    helper: dataBaseHelper,
  );

  final profileRepository = ProfileRepository(
      apiClient: apiClient, sharedPreferences: sharedPreferences);

  return [
    ChangeNotifierProvider<AuthController>(
      create: (context) => AuthController(authRepository: authRepository),
    ),
    ChangeNotifierProvider<HomeController>(
      create: (context) => HomeController(homeRepository: homeRepository),
    ),
    ChangeNotifierProvider<ProfileController>(
      create: (context) =>
          ProfileController(profileRepository: profileRepository),
    ),
    ChangeNotifierProvider<ConnectivityController>(
      create: (context) => ConnectivityController(),
    ),
  ];
}
