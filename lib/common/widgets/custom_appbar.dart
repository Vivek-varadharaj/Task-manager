import 'package:flutter/material.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // final Widget? prefixIcon;
  final String heading;
  final List<Widget>? suffixIcons;
  final bool showPrefix;
  final void Function()? onTap;
  final PreferredSizeWidget? bottom;
  final double height;

  const CustomAppBar(
      {super.key,
      required this.heading,
      this.height = 100,
      this.bottom,
      this.suffixIcons,
      this.onTap,
      this.showPrefix = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral0,
      child: AppBar(
        bottom: bottom,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: AppColors.neutral0,
        leadingWidth: 56,
        leading: showPrefix
            ? InkWell(
                onTap: onTap ??
                    () {
                      Navigator.of(context).pop();
                    },
                child: Container(
                  margin: const EdgeInsets.only(left: 16, right: 8),
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.neutral0),
                  child: const Icon(
                    Icons.keyboard_arrow_left,
                    color: AppColors.primary400,
                    size: 28,
                  ),
                ),
              )
            : null,
        title: Text(
          heading,
          style: AppTextStyles.heading3
              .copyWith(color: AppColors.primary300, fontSize: 24),
        ),
        centerTitle: false,
        actions: suffixIcons, // Takes unlimited widgets as actions
        backgroundColor: Colors.transparent, // Customize as needed
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
