import 'package:flutter/material.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/dimensions.dart';


class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.onTap});
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            Navigator.of(context).pop();
          },
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 3),
                blurRadius: 11,
                spreadRadius: 0,
              ),
            ],
            color: AppColors.neutral0,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        child: const Center(
          child: Icon(
            Icons.arrow_back,
            size: 22,
            color: AppColors.neutral70,
          ),
        ),
      ),
    );
  }
}
