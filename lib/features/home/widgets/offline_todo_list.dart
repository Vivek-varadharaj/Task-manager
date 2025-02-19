import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/features/home/controllers/home_controller.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/features/home/widgets/modal_sheet_for_edit.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/dimensions.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart'; 

class OfflineTodosList extends StatelessWidget {
  const OfflineTodosList({super.key, required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);

    final groupedTodos = groupBy(
      homeController.localTodo,
      (Todo todo) {
        if (todo.dueDate != null) {
          return DateFormat('MMM dd, yyyy')
              .format(DateTime.parse(todo.dueDate!));
        } else {
          return 'No Due Date';
        }
      },
    );

    final sortedGroupedTodos = Map.fromEntries(
      groupedTodos.entries.toList()
        ..sort((a, b) {
          if (a.key == 'No Due Date' && b.key != 'No Due Date') {
            return 1;
          } else if (b.key == 'No Due Date' && a.key != 'No Due Date') {
            return -1;
          } else {
            final dateA = DateFormat('MMM dd, yyyy').parse(a.key);
            final dateB = DateFormat('MMM dd, yyyy').parse(b.key);
            return dateA.compareTo(dateB);
          }
        }),
    );

    return Column(
      children: [
        Expanded(
          child: sortedGroupedTodos.isNotEmpty
              ? ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    height: Dimensions.paddingSizeExtraOverLarge,
                  ),
                  padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
                  itemCount: sortedGroupedTodos.length,
                  itemBuilder: (context, index) {
                    final dueDate = sortedGroupedTodos.keys.elementAt(index);
                    final todosForDueDate = sortedGroupedTodos[dueDate]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dueDate,
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ListView.separated(
                          padding: EdgeInsets.only(top: 10),
                          separatorBuilder: (context, index) =>
                              SizedBox(height: Dimensions.paddingSizeDefault),
                          shrinkWrap: true,
                          controller: homeController.offlineScrollController,
                          itemCount: todosForDueDate.length,
                          itemBuilder: (context, index) {
                            final todo = todosForDueDate[index];

                            return Slidable(
                              key: ValueKey(todo.id),
                              startActionPane: ActionPane(
                                dragDismissible: false,
                                motion: const StretchMotion(),
                                dismissible: DismissiblePane(onDismissed: () {
                                  homeController.deleteTodo(todo.id);
                                }),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      homeController.deleteTodo(todo.id);
                                    },
                                    backgroundColor: AppColors.alertRed,
                                    foregroundColor: AppColors.neutral0,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              endActionPane: (todo.completed == 0)
                                  ? ActionPane(
                                      dragDismissible: false,
                                      motion: const StretchMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            addOrEditToDo(
                                                context: context,
                                                isLocal: true,
                                                tabController: tabController,
                                                todo: todo);
                                          },
                                          backgroundColor: AppColors.alertGold,
                                          foregroundColor: AppColors.neutral0,
                                          icon: Icons.edit,
                                          label: 'Edit',
                                        ),
                                        SlidableAction(
                                          onPressed: (context) {
                                            homeController.assignValues(todo);
                                            homeController.editTodo(
                                              todo.copyWith(completed: 1),
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
                                leading: Icon(Icons.circle_outlined,
                                    color: todo.priority == TodoPriority.high
                                        ? AppColors.alertRed
                                        : todo.priority == TodoPriority.medium
                                            ? AppColors.alertGold
                                            : AppColors.alertGreen),
                                trailing: todo.completed == 1
                                    ? const Icon(
                                        Icons.done,
                                        color: AppColors.neutral0,
                                      )
                                    : const SizedBox(),
                                onTap: () {
                                  addOrEditToDo(
                                      context: context,
                                      tabController: tabController,
                                      todo: todo);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                ),
                                tileColor: todo.completed == 1
                                    ? AppColors.alertGreen.withOpacity(0.65)
                                    : AppColors.neutral0.withOpacity(0.65),
                                title: Text(
                                  todo.todo,
                                  style: AppTextStyles.para2.copyWith(
                                      color: (todo.completed == 0)
                                          ? AppColors.neutral100
                                          : AppColors.neutral0),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
