
import 'package:flutter/material.dart';

import 'package:task_manager_app/features/profile/domain/repository/profile_repository.dart';


class ProfileController extends ChangeNotifier {
  final ProfileRepository profileRepository;
  ProfileController({required this.profileRepository});

 

  Future<void> getProfile() async {
  
    notifyListeners();
  }
}
