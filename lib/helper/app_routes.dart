import 'package:flutter/material.dart';
import 'package:task_manager_app/features/auth/screens/login_screen.dart';
import 'package:task_manager_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:task_manager_app/features/home/screens/home_screen.dart';
import 'package:task_manager_app/features/splash/screens/splash_screen.dart';

class Routes {
  Routes._();

  static const home = '/home';
  static const profile = '/profile';
  static const login = "/login";
  static const splash = "/splash";
  static const verifyOtp = "/verifyOtp";
  static const enterName = "/enterName";
  static const dashboard = "/dashboard";
  static const search = "/search";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route Not Found')),
          ),
        );
    }
  }
}
