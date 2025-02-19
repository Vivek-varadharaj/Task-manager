import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:task_manager_app/common/widgets/custom_button.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/app_texts.dart';
import 'package:task_manager_app/util/dimensions.dart';

class CommonDialogueDisplay extends StatefulWidget {
  final Function? onOkClick;
  final String? text;
  final String? deleteText;
  final String? labelText;

  CommonDialogueDisplay(
      {this.onOkClick, this.text, this.deleteText, this.labelText});

  @override
  _CommonDialogueDisplayState createState() => _CommonDialogueDisplayState();
}

class _CommonDialogueDisplayState extends State<CommonDialogueDisplay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.neutral0,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.labelText ?? "",
                          style: AppTextStyles.heading7,
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.close))
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24.0,
                      ),
                      Text(
                        widget.text ?? "",
                        style: AppTextStyles.heading3,
                      ),
                      SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CustomButton(
                        isLoading: false,
                        title: AppTexts.cancel,
                        backgroundColor: AppColors.primary300,
                        textColor: AppColors.neutral0,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(height: Dimensions.paddingSizeExtraLarge),
                      CustomButton(
                        isLoading: false,
                        title: widget.deleteText ?? "",
                        backgroundColor: AppColors.neutral0,
                        textColor: AppColors.alertRed,
                        onTap: () => widget.onOkClick!(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
