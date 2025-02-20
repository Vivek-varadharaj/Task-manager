import 'package:flutter/material.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/dimensions.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key,
      this.controller,
      this.obscureText = false,
      this.textColor = AppColors.neutral100,
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
  final Color textColor;

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
      child: Row(
        children: [
          Expanded(
            child: TextField(
                style: AppTextStyles.heading7
                    .copyWith(fontSize: Dimensions.fontSizeDefault),
                obscureText: widget.obscureText,
                keyboardType: widget.textInputType,
                onChanged: widget.onChanged,
                controller: widget.controller,
                scrollPadding: EdgeInsets.zero,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: -10.0),
                  suffixIconConstraints: const BoxConstraints(maxHeight: 14),
                  isCollapsed: true,
                  hintText: widget.hintText,
                  hintStyle: AppTextStyles.heading7.copyWith(
                      color: widget.textColor,
                      fontSize: Dimensions.fontSizeDefault),
                  border: InputBorder.none,
                )),
          ),
          if (widget.suffixIcon != null) widget.suffixIcon!,
        ],
      ),
    );
  }
}
