import 'package:flutter/material.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/dimensions.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile(
      {super.key, required this.heading, required this.subheading});
  final String heading;
  final String subheading;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: AppTextStyles.heading7.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.neutral50),
        ),
        SizedBox(
          height: Dimensions.paddingSizeSmall,
        ),
        Text(
          subheading,
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700),
        )
      ],
    );
  }
}
