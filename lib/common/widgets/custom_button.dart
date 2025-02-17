import 'package:flutter/material.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/dimensions.dart';



class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      this.backgroundColor,
      this.textColor,
      this.fontSize,
      this.onTap,
      this.title,
      required this.isLoading});
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final GestureTapCallback? onTap;
  final String? title;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 51,
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
            backgroundColor: backgroundColor ?? AppColors.primary400,
            textStyle: AppTextStyles.button,
          ),
          onPressed: onTap ?? () {},
          child: isLoading
              ? const Center(
                  child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.neutral0,
                      )))
              : Text(
                  title ?? "",
                  style: AppTextStyles.button,
                )),
    );
  }
}
