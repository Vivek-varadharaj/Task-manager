import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/features/home/controllers/home_controller.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/features/home/widgets/modal_sheet_for_edit.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/dimensions.dart';

class OfflineTodosList extends StatelessWidget {
  const OfflineTodosList({super.key, required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);

    return Column(
      children: [
        Expanded(
          child: homeController.localTodo.isNotEmpty
              ? ListView.separated(
                  padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
                  separatorBuilder: (context, index) =>
                      SizedBox(height: Dimensions.paddingSizeDefault),
                  controller: homeController.offlineScrollController,
                  itemCount: homeController.localTodo.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      key: ValueKey(homeController.localTodo[index].id),
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        dismissible: DismissiblePane(onDismissed: () {
                          homeController
                              .deleteTodo(homeController.localTodo[index].id);
                        }),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              homeController.deleteTodo(
                                  homeController.localTodo[index].id);
                            },
                            backgroundColor: AppColors.alertRed,
                            foregroundColor: AppColors.neutral0,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              addOrEditToDo(
                                  context: context,
                                  isLocal: true,
                                  tabController: tabController,
                                  todo: homeController.localTodo[index]);
                            },
                            backgroundColor: AppColors.alertGreen,
                            foregroundColor: AppColors.neutral0,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          if (homeController.localTodo[index].completed == 0)
                            SlidableAction(
                              onPressed: (context) {
                                homeController.assignValues(
                                    homeController.localTodo[index]);
                                homeController.editTodo(
                                  homeController.localTodo[index]
                                      .copyWith(completed: 1),
                                );
                              },
                              backgroundColor: AppColors.alertGold,
                              foregroundColor: AppColors.neutral0,
                              icon: Icons.done,
                              label: 'Complete',
                            ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          addOrEditToDo(
                              context: context,
                              tabController: tabController,
                              todo: homeController.localTodo[index]);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        tileColor: AppColors.neutral0.withOpacity(0.65),
                        title: Text(homeController.localTodo[index].todo),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    "Add your first Todo",
                    style: AppTextStyles.button,
                  ),
                ),
        ),
        if (homeController.isOfflineLoading && homeController.skip != 0)
          const Center(
              child: CircularProgressIndicator(color: AppColors.primary100)),
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
