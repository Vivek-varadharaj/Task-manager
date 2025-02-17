import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/api/api_provider.dart';
import 'package:task_manager_app/features/auth/controllers/auth_controller.dart';
import 'package:task_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager_app/features/splash/screens/splash_screen.dart';
import 'package:task_manager_app/helper/app_routes.dart';
import 'package:task_manager_app/helper/dependency_injection.dart';
import 'package:task_manager_app/helper/global_keys.dart';
import 'package:task_manager_app/util/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final providers = await initProviders();
  runApp(MyApp(
    providers: providers,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.providers});
  final List<ChangeNotifierProvider> providers;


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        onGenerateRoute: Routes.generateRoute,
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.splash,
        home: const SplashScreen(),
      ),
    );
  }
}
