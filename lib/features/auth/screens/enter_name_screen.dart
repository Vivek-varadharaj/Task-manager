import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/common/widgets/custom_back_button.dart';
import 'package:task_manager_app/common/widgets/custom_button.dart';
import 'package:task_manager_app/common/widgets/custom_text_field.dart';
import 'package:task_manager_app/util/app_texts.dart';

import 'package:task_manager_app/util/dimensions.dart';


import 'package:task_manager_app/features/auth/controllers/auth_controller.dart';


class EnterNameScreen extends StatefulWidget {
  const EnterNameScreen({Key? key}) : super(key: key);

  @override
  State<EnterNameScreen> createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  Future<void> register() async {
    if (controller.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.enterValidName)),
      );
      return;
    }
  
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomBackButton(),
              SizedBox(height: Dimensions.paddingSizeExtraOverLarge),
              CustomTextField(
                controller: controller,
                hintText: AppTexts.enterName,
              ),
              SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  return CustomButton(
                    isLoading: authController.isLoading,
                    onTap: register,
                    title: AppTexts.submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
