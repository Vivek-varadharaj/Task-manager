import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:task_manager_app/common/widgets/custom_appbar.dart';

import 'package:task_manager_app/features/home/controllers/home_controller.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/features/home/widgets/modal_sheet_for_edit.dart';

import 'package:task_manager_app/features/home/widgets/offline_todo_list.dart';
import 'package:task_manager_app/features/home/widgets/online_todo_list.dart';
import 'package:task_manager_app/helper/app_routes.dart';

import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/app_texts.dart';
import 'package:task_manager_app/util/dimensions.dart';
import 'package:task_manager_app/util/images.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late HomeController homeController;

  @override
  void initState() {
    homeController = Provider.of<HomeController>(context, listen: false);
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((d) {
      homeController.loadTodos();
      homeController.loadOfflineTodos();
    });

    homeController.scrollController.addListener(() {
      if (homeController.scrollController.position.pixels ==
          homeController.scrollController.position.maxScrollExtent) {
        if (!homeController.isLoading && homeController.hasMore) {
          homeController.loadTodos();
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
              addOrEditToDo(context: context, tabController: _tabController);
            },
            child: const Icon(
              Icons.add,
              color: AppColors.neutral0,
            )),
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          suffixIcons: [
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.profile);
              },
              child: const Icon(
                Icons.person,
                color: AppColors.neutral0,
              ),
            ),
            SizedBox(
              width: Dimensions.paddingSizeDefault,
            ),
          ],
          heading: AppTexts.tasks,
          showPrefix: false,
          bottom: TabBar(
            dividerHeight: 0,
            indicatorColor: AppColors.primary300,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: AppColors.primary100,
            labelStyle:
                AppTextStyles.button.copyWith(color: AppColors.primary300),
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
                      OnlineTodosList(
                        tabController: _tabController,
                      ),
                      OfflineTodosList(
                        tabController: _tabController,
                      )
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
