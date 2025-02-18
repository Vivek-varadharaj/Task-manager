import 'package:flutter/material.dart';
import 'package:task_manager_app/features/auth/domain/models/login_response_model.dart';

import 'package:task_manager_app/features/profile/domain/repository/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository profileRepository;
  ProfileController({required this.profileRepository}) {
    getProfile();
  }

  LoginResponseModel? user;

  Future<void> getProfile() async {
    try {
      user = await profileRepository.getUser();
    } catch (e) {
      print("Error fetching profile");
    } finally {
      notifyListeners();
    }
  }
}
