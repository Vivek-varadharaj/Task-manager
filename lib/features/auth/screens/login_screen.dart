import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/common/models/response_model.dart';

import 'package:task_manager_app/common/widgets/custom_button.dart';
import 'package:task_manager_app/common/widgets/custom_text_field.dart';
import 'package:task_manager_app/features/auth/controllers/auth_controller.dart';
import 'package:task_manager_app/features/auth/domain/models/login_request_model.dart';
import 'package:task_manager_app/features/internet_connectivity/controllers/controller.dart';
import 'package:task_manager_app/helper/app_routes.dart';
import 'package:task_manager_app/helper/global_keys.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/app_texts.dart';
import 'package:task_manager_app/util/dimensions.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final LoginRequestModel loginRequestModel =
      LoginRequestModel(username: "", password: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ConnectivityController>(
            builder: (context, connectivityController, child) {
          return connectivityController.isConnected
              ? SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        Text(AppTexts.login, style: AppTextStyles.heading1),
                        SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(
                          AppTexts.letsConenct,
                          style: AppTextStyles.para2
                              .copyWith(color: AppColors.neutral60),
                        ),
                        SizedBox(height: Dimensions.paddingSizeExtraOverLarge),
                        Row(
                          children: [
                            SizedBox(width: Dimensions.paddingSizeLarge),
                            Expanded(
                              child: CustomTextField(
                                textInputType: TextInputType.name,
                                onChanged: (value) {
                                  loginRequestModel.username = value ?? "";
                                },
                                hintText: AppTexts.enterUsername,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.paddingSizeLarge),
                        Row(
                          children: [
                            SizedBox(width: Dimensions.paddingSizeLarge),
                            Expanded(
                              child: Consumer<AuthController>(
                                  builder: (context, authController, child) {
                                return CustomTextField(
                                  obscureText: authController.obsecureText,
                                  suffixIcon: InkWell(
                                    onTap: () {},
                                    child: Icon(authController.obsecureText
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                  ),
                                  textInputType: TextInputType.visiblePassword,
                                  onChanged: (value) {
                                    loginRequestModel.password = value ?? "";
                                  },
                                  hintText: AppTexts.enterPassword,
                                );
                              }),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.paddingSizeExtremeLarge),
                        Consumer<AuthController>(
                          builder: (context, authController, child) {
                            return CustomButton(
                              isLoading: authController.isLoading,
                              onTap: () {
                                loginUsingPassword(authController, context);
                              },
                              title: AppTexts.continueText,
                              backgroundColor: AppColors.primary400,
                            );
                          },
                        ),
                        SizedBox(height: Dimensions.paddingSizeExtremeLarge),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                            children: [
                              TextSpan(
                                text: AppTexts.byAccepting,
                                style: AppTextStyles.para5
                                    .copyWith(fontWeight: FontWeight.w300),
                              ),
                              TextSpan(
                                text: AppTexts.termsOfUse,
                                style: AppTextStyles.para5.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 2,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                              TextSpan(
                                text: " & ",
                                style: AppTextStyles.para5.copyWith(
                                  height: 0.5,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 2,
                                ),
                              ),
                              TextSpan(
                                text: AppTexts.privacyPolicy,
                                style: AppTextStyles.para5.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 2,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(
                    Dimensions.paddingSizeLarge,
                  ),
                  child: Center(
                      child: Text(
                    "No internet connection",
                    style: AppTextStyles.heading3,
                  )),
                );
        }),
      ),
    );
  }

  loginUsingPassword(
      AuthController authController, BuildContext context) async {
    if (loginRequestModel.username.isEmpty) {
      return scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text("Please enter a username")));
    } else if (loginRequestModel.password.isEmpty) {
      return scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text("Please enter a password")));
    } else {
      ResponseModel responseModel = await authController.loginUsingPassword(
          loginRequestModel: loginRequestModel.toJson());
      if (!responseModel.isSuccess) {
        return scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(responseModel.message ?? "Login failed")));
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home,
          (route) => false,
        );
      }
    }
  }
}
