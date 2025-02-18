import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/common/models/response_model.dart';
import 'package:task_manager_app/common/widgets/custom_appbar.dart';
import 'package:task_manager_app/common/widgets/custom_button.dart';
import 'package:task_manager_app/common/widgets/custom_text_field.dart';
import 'package:task_manager_app/features/home/controllers/home_controller.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/helper/global_keys.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/app_texts.dart';
import 'package:task_manager_app/util/dimensions.dart';
import 'package:task_manager_app/util/images.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late TextEditingController _todoController;
  late TextEditingController _descriptionController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((d) {
      Provider.of<HomeController>(context, listen: false).loadTodos();
      Provider.of<HomeController>(context, listen: false).loadOfflineTodos();
    });

    _todoController = TextEditingController();
    _descriptionController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final controller = Provider.of<HomeController>(context, listen: false);
        if (!controller.isLoading && controller.hasMore) {
          controller.loadTodos();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                Images.background,
              ),
              fit: BoxFit.cover)),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary300,
            onPressed: () {
              addOrEditToDo();
            },
            child: const Icon(
              Icons.add,
              color: AppColors.neutral0,
            )),
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          heading: AppTexts.tasks,
          showPrefix: false,
          bottom: TabBar(
            indicatorColor: AppColors.neutral0,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: AppColors.primary100,
            labelStyle:
                AppTextStyles.button.copyWith(color: AppColors.neutral0),
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'Online',
              ),
              Tab(text: 'Offline'),
            ],
          ),
        ),
        resizeToAvoidBottomInset: true,
        body:
            Consumer<HomeController>(builder: (context, homeController, child) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      (homeController.isLoading && homeController.skip == 0)
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.neutral0))
                          : Column(
                              children: [
                                Expanded(
                                  child: homeController.isButtonLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                              color: AppColors.neutral0))
                                      : ListView.separated(
                                          padding: EdgeInsets.all(
                                              Dimensions.paddingSizeLarge),
                                          separatorBuilder: (context, index) =>
                                              SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault),
                                          controller: _scrollController,
                                          itemCount:
                                              homeController.todos.length,
                                          itemBuilder: (context, index) {
                                            return Slidable(
                                              key: ValueKey(homeController
                                                  .todos[index].id),
                                              startActionPane: ActionPane(
                                                motion: const ScrollMotion(),
                                                dismissible: DismissiblePane(
                                                    onDismissed: () {
                                                  deleteTodo(homeController
                                                      .todos[index].id);
                                                }),
                                                children: [
                                                  SlidableAction(
                                                    onPressed: (context) {
                                                      deleteTodo(homeController
                                                          .todos[index].id);
                                                    },
                                                    backgroundColor:
                                                        AppColors.alertRed,
                                                    foregroundColor:
                                                        AppColors.neutral0,
                                                    icon: Icons.delete,
                                                    label: 'Delete',
                                                  ),
                                                ],
                                              ),
                                              endActionPane: ActionPane(
                                                motion: const ScrollMotion(),
                                                children: [
                                                  SlidableAction(
                                                    flex: 1,
                                                    onPressed: (context) {
                                                      addOrEditToDo(
                                                          todo: homeController
                                                              .todos[index]);
                                                    },
                                                    backgroundColor:
                                                        AppColors.alertGreen,
                                                    foregroundColor:
                                                        AppColors.neutral0,
                                                    icon: Icons.edit,
                                                    label: 'Edit',
                                                  ),
                                                  SlidableAction(
                                                    flex: 1,
                                                    onPressed: (context) {
                                                      homeController.editTodo(
                                                          homeController
                                                              .todos[index]
                                                              .copyWith(
                                                                  completed:
                                                                      1));
                                                    },
                                                    backgroundColor:
                                                        AppColors.alertGold,
                                                    foregroundColor:
                                                        AppColors.neutral0,
                                                    icon: Icons.done,
                                                    label: 'Complete',
                                                  ),
                                                ],
                                              ),
                                              child: ListTile(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault),
                                                ),
                                                tileColor: AppColors.neutral0
                                                    .withOpacity(0.65),
                                                title: Text(homeController
                                                    .todos[index].todo),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                if (homeController.isLoading)
                                  const Center(
                                      child: CircularProgressIndicator(
                                          color: AppColors.primary100)),
                              ],
                            ),
                      Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              padding:
                                  EdgeInsets.all(Dimensions.paddingSizeLarge),
                              separatorBuilder: (context, index) => SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                              controller: _scrollController,
                              itemCount: homeController.localTodo.length,
                              itemBuilder: (context, index) {
                                return Slidable(
                                  key: ValueKey(
                                      homeController.localTodo[index].id),
                                  startActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    dismissible:
                                        DismissiblePane(onDismissed: () async {
                                      await deleteTodo(
                                          homeController.localTodo[index].id);
                                    }),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          deleteTodo(homeController
                                              .localTodo[index].id);
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
                                        flex: 2,
                                        onPressed: (context) {
                                          addOrEditToDo(
                                              todo: homeController
                                                  .localTodo[index]);
                                        },
                                        backgroundColor: AppColors.alertGreen,
                                        foregroundColor: AppColors.neutral0,
                                        icon: Icons.edit,
                                        label: 'Edit',
                                      ),
                                      if (homeController
                                              .localTodo[index].completed ==
                                          0)
                                        SlidableAction(
                                          flex: 2,
                                          onPressed: (context) {
                                            homeController.editTodo(
                                                homeController.localTodo[index]
                                                    .copyWith(completed: 1));
                                          },
                                          backgroundColor: AppColors.alertGold,
                                          foregroundColor: AppColors.neutral0,
                                          icon: Icons.done,
                                          label: 'Complete',
                                        ),
                                    ],
                                  ),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault),
                                    ),
                                    tileColor:
                                        AppColors.primary100.withOpacity(0.5),
                                    title: Text(
                                        homeController.localTodo[index].todo),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (homeController.isOfflineLoading &&
                              homeController.skip != 0)
                            const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary100)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  deleteTodo(int id) async {
    ResponseModel responseModel =
        await Provider.of<HomeController>(context, listen: false)
            .deleteTodo(id);
    if (!responseModel.isSuccess) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content: Text(responseModel.message ?? "Something went wrong")));
    }
  }

  addOrEditToDo({Todo? todo}) {
    _todoController.clear();
    _descriptionController.clear();
    Provider.of<HomeController>(context, listen: false)
        .toggleDueDate(DateTime.parse(DateTime.now().toString()));
    Provider.of<HomeController>(context, listen: false)
        .togglePriority(TodoPriority.high);

    bool isForEdit = false;
    if (todo != null) {
      isForEdit = true;
      _todoController.text = todo.todo;
      _descriptionController.text = todo.description ?? "";
      Provider.of<HomeController>(context, listen: false).toggleDueDate(
          DateTime.parse(todo.dueDate ?? DateTime.now().toString()));
      Provider.of<HomeController>(context, listen: false)
          .togglePriority(todo.priority ?? TodoPriority.high);
    }
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: AppColors.neutral0,
      context: context,
      builder: (context) => Builder(builder: (context) {
        return Container(
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: ListView(
            shrinkWrap: true,
            children: [
              CustomTextField(
                textColor: AppColors.neutral10,
                controller: _todoController,
                hintText: AppTexts.addTodo,
              ),
              SizedBox(
                height: Dimensions.paddingSizeDefault,
              ),
              Text(
                "Priority",
                style:
                    AppTextStyles.button.copyWith(color: AppColors.neutral100),
              ),
              SizedBox(
                height: Dimensions.paddingSizeSmall,
              ),
              Consumer<HomeController>(
                  builder: (context, homeController, child) {
                return Wrap(
                  runSpacing: Dimensions.paddingSizeSmall,
                  spacing: Dimensions.paddingSizeSmall,
                  children: TodoPriority.values
                      .map(
                        (e) => ChoiceChip(
                          showCheckmark: false,
                          label: Text(e.name),
                          selected: homeController.priority.name == e.name,
                          onSelected: (value) {
                            homeController.togglePriority(e);
                          },
                        ),
                      )
                      .toList(),
                );
              }),
              SizedBox(
                height: Dimensions.paddingSizeDefault,
              ),
              Text(
                "Due date",
                style:
                    AppTextStyles.button.copyWith(color: AppColors.neutral100),
              ),
              SizedBox(
                height: Dimensions.paddingSizeSmall,
              ),
              Consumer<HomeController>(
                  builder: (context, homeController, child) {
                return CustomButton(
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                        initialDate: DateTime.now(),
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)));

                    if (date != null) {
                      homeController.toggleDueDate(date);
                    }
                  },
                  textColor: AppColors.primary300,
                  backgroundColor: Colors.transparent,
                  isLoading: homeController.isButtonLoading,
                  title:
                      DateFormat("MMM d, yyyy").format(homeController.dueDate),
                );
              }),
              SizedBox(
                height: Dimensions.paddingSizeDefault,
              ),
              TextField(
                maxLines: 8,
                minLines: 3,
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter your text...",
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.primary300, width: 1),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault)),
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.primary300, width: 1),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault)),
                ),
              ),
              SizedBox(
                height: Dimensions.paddingSizeDefault,
              ),
              Consumer<HomeController>(
                  builder: (context, homeController, child) {
                return CustomButton(
                  isLoading: homeController.isButtonLoading,
                  title: AppTexts.add,
                  onTap: () async {
                    ResponseModel responseModel;
                    if (isForEdit) {
                      responseModel = await Provider.of<HomeController>(context,
                              listen: false)
                          .editTodo(todo!.copyWith(
                              completed: todo.completed,
                              description: _descriptionController.text.trim(),
                              priority: homeController.priority,
                              dueDate: homeController.dueDate.toString(),
                              todo: _todoController.text.trim()));
                    } else {
                      responseModel = await Provider.of<HomeController>(context,
                              listen: false)
                          .addTodo(_todoController.text.trim(), 1,
                              _descriptionController.text.trim());
                      _tabController.index = 1;
                    }

                    if (responseModel.isSuccess) {
                      Navigator.of(context).pop();
                    } else {
                      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
                          content: SnackBar(
                              content:
                                  Text(responseModel.message ?? "Failed"))));
                    }
                  },
                );
              })
            ],
          ),
        );
      }),
    );
  }
}
