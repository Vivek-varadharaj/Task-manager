import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/common/models/response_model.dart';
import 'package:task_manager_app/common/widgets/custom_button.dart';
import 'package:task_manager_app/common/widgets/custom_text_field.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';

import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/app_texts.dart';
import 'package:task_manager_app/util/dimensions.dart';
import '../controllers/home_controller.dart';

class TodoBottomSheet extends StatelessWidget {
  final bool isForEdit;
  final bool isLocal;
  final Todo? todo;
  final TabController tabController;

  const TodoBottomSheet({
    super.key,
    required this.isForEdit,
    required this.isLocal,
    this.todo,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context);

    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: ListView(
        shrinkWrap: true,
        children: [
          CustomTextField(
            textColor: AppColors.neutral10,
            controller: homeController.todoController,
            hintText: AppTexts.addTodo,
          ),
          SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            "Priority",
            style: AppTextStyles.button.copyWith(color: AppColors.neutral100),
          ),
          SizedBox(height: Dimensions.paddingSizeSmall),
          Wrap(
            runSpacing: Dimensions.paddingSizeSmall,
            spacing: Dimensions.paddingSizeSmall,
            children: TodoPriority.values
                .map(
                  (e) => ChoiceChip(
                    selectedColor: e == TodoPriority.high
                        ? AppColors.alertRed
                        : e == TodoPriority.medium
                            ? AppColors.alertGold
                            : AppColors.alertGreen,
                    backgroundColor: e == TodoPriority.high
                        ? AppColors.alertRed
                        : e == TodoPriority.medium
                            ? AppColors.alertGold
                            : AppColors.alertGreen,
                    showCheckmark: true,
                    checkmarkColor: AppColors.neutral0,
                    label: Text(
                      e.name,
                      style: AppTextStyles.latoPara
                          .copyWith(color: AppColors.neutral0),
                    ),
                    selected: homeController.priority == e,
                    onSelected: (value) {
                      homeController.togglePriority(e);
                    },
                  ),
                )
                .toList(),
          ),
          SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            "Due date",
            style: AppTextStyles.button.copyWith(color: AppColors.neutral100),
          ),
          SizedBox(height: Dimensions.paddingSizeSmall),
          CustomButton(
            onTap: () async {
              DateTime? date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );

              if (date != null) {
                homeController.toggleDueDate(date);
              }
            },
            textColor: AppColors.primary300,
            backgroundColor: Colors.transparent,
            isLoading: homeController.isButtonLoading,
            title: DateFormat("MMM d, yyyy").format(homeController.dueDate),
          ),
          SizedBox(height: Dimensions.paddingSizeDefault),
          TextField(
            style: AppTextStyles.heading7
                .copyWith(fontSize: Dimensions.fontSizeDefault),
            maxLines: 8,
            minLines: 3,
            controller: homeController.descriptionController,
            decoration: InputDecoration(
              hintStyle: AppTextStyles.heading7.copyWith(
                  color: AppColors.neutral10,
                  fontSize: Dimensions.fontSizeDefault),
              hintText: "Enter your text...",
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.primary300, width: 1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.primary300, width: 1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
          ),
          SizedBox(height: Dimensions.paddingSizeDefault),
          Consumer<HomeController>(
            builder: (context, homeController, child) =>
                homeController.message != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          homeController.message ?? "",
                          style: AppTextStyles.latoPara
                              .copyWith(color: AppColors.alertRed),
                        ),
                      )
                    : const SizedBox(),
          ),
          CustomButton(
            isLoading: homeController.isButtonLoading,
            title: isForEdit ? AppTexts.save : AppTexts.add,
            onTap: () async {
              String? message =
                  Provider.of<HomeController>(context, listen: false)
                      .validateTodo();

              if (message == null) {
                ResponseModel responseModel;
                if (isForEdit) {
                  log("This is for editing");
                  responseModel =
                      await homeController.editTodo(todo!, isLocal: isLocal);
                } else {
                  responseModel = await homeController.addTodo();
                  tabController.index = 1;
                }

                if (responseModel.isSuccess) {
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(responseModel.message ?? "Failed")),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
