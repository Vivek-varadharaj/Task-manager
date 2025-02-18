import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      body: SafeArea(
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
                Text(
                  AppTexts.myProfile,
                  style: AppTextStyles.heeboHeading.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: AppColors.primary100),
                ),
                SizedBox(
                  height: Dimensions.paddingSizeExtraOverLarge,
                ),
                ProfileTile(heading: AppTexts.name, subheading: ""),
                SizedBox(
                  height: Dimensions.paddingSizeExtraLarge,
                ),
                ProfileTile(heading: AppTexts.phone, subheading: ""),
                SizedBox(
                  height: (Dimensions.paddingSizeExtraOverLarge),
                ),
                Center(
                  child: TextButton(
                      onPressed: () async {
                        bool loggedOut = await Provider.of<AuthController>(
                                context,
                                listen: false)
                            .logout();
                        if (loggedOut) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.login,
                            (route) => false,
                          );
                        }
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
      ),
    );
  }
}
