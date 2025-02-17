import 'package:task_manager_app/api/api_provider.dart';

class ApiChecker {
  static void checkApi(ApiResponse response, {bool showSnackbar = false}) {
    if (response.statusCode == 401) {
      // Provider.of<AuthController>(context, listen: false).logout();
    } else {
      String message;
      if (response.statusText != null && response.statusText!.isNotEmpty) {
        message = response.statusText!;
      } else if (response.body is Map && response.body['message'] != null) {
        message = response.body['message'];
      } else {
        message = "Failed";
      }
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(message)),
      // );
    }
  }
}
