import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/common/widgets/common_dialog_display.dart';
import 'package:task_manager_app/common/widgets/custom_appbar.dart';
import 'package:task_manager_app/features/auth/controllers/auth_controller.dart';
import 'package:task_manager_app/features/profile/controllers/profile_controller.dart';
import 'package:task_manager_app/features/profile/widgets/profile_tile.dart';
import 'package:task_manager_app/helper/app_routes.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/app_texts.dart';
import 'package:task_manager_app/util/dimensions.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        heading: AppTexts.myProfile,
        height: 60,
      ),
      body: Consumer<ProfileController>(
          builder: (context, profileController, child) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Consumer<ProfileController>(
                builder: (context, profileController, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: Dimensions.paddingSizeDefault,
                  ),
                  ProfileTile(
                      heading: AppTexts.name,
                      subheading: profileController.user?.firstName ?? ""),
                  SizedBox(
                    height: Dimensions.paddingSizeExtraLarge,
                  ),
                  ProfileTile(
                      heading: AppTexts.email,
                      subheading: profileController.user?.email ?? ""),
                  SizedBox(
                    height: (Dimensions.paddingSizeExtraLarge),
                  ),
                  ProfileTile(
                      heading: AppTexts.gender,
                      subheading: profileController.user?.gender ?? ""),
                  SizedBox(
                    height: (Dimensions.paddingSizeExtraOverLarge),
                  ),
                  Center(
                    child: TextButton(
                        onPressed: () async {
                          showLogoutDialogue(context);
                        },
                        child: Text(
                          AppTexts.logout,
                          style: AppTextStyles.button
                              .copyWith(color: AppColors.primary400),
                        )),
                  )
                ],
              );
            }),
          ),
        );
      }),
    );
  }

  showLogoutDialogue(
    BuildContext context,
  ) {
    return showGeneralDialog(
      barrierLabel: AppTexts.logout,
      barrierDismissible: true,
      transitionDuration: const Duration(),
      context: context,
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      ),
      pageBuilder: (context, anim1, anim2) {
        return CommonDialogueDisplay(
          text: AppTexts.logoutDesc,
          deleteText: AppTexts.logout,
          labelText: AppTexts.logout,
          onOkClick: () async {
            bool loggedOut =
                await Provider.of<AuthController>(context, listen: false)
                    .logout();
            if (loggedOut) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.login,
                (route) => false,
              );
            }
          },
        );
      },
    );
  }
}
