import 'package:flutter/material.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/dimensions.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key,
      this.controller,
      this.obscureText = false,
      this.hintText,
      this.onChanged,
      this.textInputType,
      this.suffixIcon});

  final TextEditingController? controller;
  final String? hintText;
  final Function(String?)? onChanged;
  final TextInputType? textInputType;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.neutral10))),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      child: TextField(
          obscureText: widget.obscureText,
          keyboardType: widget.textInputType,
          onChanged: widget.onChanged,
          controller: widget.controller,
          scrollPadding: EdgeInsets.zero,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: -10.0),
            suffixIconConstraints: BoxConstraints(maxHeight: 14),
            suffixIcon: widget.suffixIcon,
            isCollapsed: true,
            hintText: widget.hintText,
            hintStyle: AppTextStyles.heading7.copyWith(
                color: AppColors.neutral80,
                fontSize: Dimensions.fontSizeDefault),
            border: InputBorder.none,
          )),
    );
  }
}
