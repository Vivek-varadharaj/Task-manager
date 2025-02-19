import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/features/home/controllers/home_controller.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/features/home/widgets/modal_sheet_for_edit.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/dimensions.dart';

class OnlineTodosList extends StatelessWidget {
  const OnlineTodosList({super.key, required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);

    return homeController.isLoading && homeController.skip == 0
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.neutral0))
        : Column(
            children: [
              Expanded(
                child: homeController.isButtonLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.neutral0))
                    : ListView.separated(
                        padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: Dimensions.paddingSizeDefault),
                        controller: homeController.scrollController,
                        itemCount: homeController.todos.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            key: ValueKey(homeController.todos[index].id),
                            startActionPane: ActionPane(
                              dragDismissible: false,
                              motion: const StretchMotion(),
                              dismissible: DismissiblePane(onDismissed: () {
                                homeController
                                    .deleteTodo(homeController.todos[index].id);
                              }),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    homeController.deleteTodo(
                                        homeController.todos[index].id);
                                  },
                                  backgroundColor: AppColors.alertRed,
                                  foregroundColor: AppColors.neutral0,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            endActionPane: (homeController
                                        .todos[index].completed ==
                                    0)
                                ? ActionPane(
                                    dragDismissible: false,
                                    motion: const StretchMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          addOrEditToDo(
                                            todo: homeController.todos[index],
                                            tabController: tabController,
                                            context: context,
                                          );
                                        },
                                        backgroundColor: AppColors.alertGold,
                                        foregroundColor: AppColors.neutral0,
                                        icon: Icons.edit,
                                        label: 'Edit',
                                      ),
                                      SlidableAction(
                                        onPressed: (context) {
                                          homeController.assignValues(
                                              homeController.todos[index]);
                                          homeController.editTodo(
                                            homeController.todos[index]
                                                .copyWith(completed: 1),
                                          );
                                        },
                                        backgroundColor: AppColors.alertGreen,
                                        foregroundColor: AppColors.neutral0,
                                        icon: Icons.done,
                                        label: 'Complete',
                                      ),
                                    ],
                                  )
                                : null,
                            child: ListTile(
                              trailing:
                                  homeController.todos[index].completed == 1
                                      ? const Icon(
                                          Icons.done,
                                          color: AppColors.neutral0,
                                        )
                                      : const SizedBox(),
                              onTap: () {
                                addOrEditToDo(
                                    context: context,
                                    tabController: tabController,
                                    isLocal: false,
                                    todo: homeController.todos[index]);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                              ),
                              tileColor:
                                  homeController.todos[index].completed == 1
                                      ? AppColors.alertGreen.withOpacity(0.65)
                                      : AppColors.primary100.withOpacity(0.65),
                              title: Text(homeController.todos[index].todo,
                                  style: AppTextStyles.para2.copyWith(
                                      color: (homeController
                                                  .todos[index].completed ==
                                              0)
                                          ? AppColors.neutral100
                                          : AppColors.neutral0)),
                            ),
                          );
                        },
                      ),
              ),
              if (homeController.isLoading)
                const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary100)),
            ],
          );
  }

  addOrEditToDo({
    Todo? todo,
    bool isLocal = true,
    required BuildContext context,
    required TabController tabController,
  }) {
    Provider.of<HomeController>(context, listen: false).clearEditFields();
    bool isForEdit = false;
    if (todo != null) {
      isForEdit = true;
      Provider.of<HomeController>(context, listen: false).assignValues(todo);
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => TodoBottomSheet(
        isForEdit: isForEdit,
        isLocal: isLocal,
        tabController: tabController,
        todo: todo,
      ),
    );
  }
}
