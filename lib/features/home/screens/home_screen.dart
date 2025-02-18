import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/common/widgets/custom_button.dart';
import 'package:task_manager_app/common/widgets/custom_text_field.dart';
import 'package:task_manager_app/features/home/controllers/home_controller.dart';
import 'package:task_manager_app/util/app_texts.dart';
import 'package:task_manager_app/util/dimensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  late TextEditingController _todoController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((d) {
      Provider.of<HomeController>(context, listen: false).loadTodos();
    });
    _todoController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Trigger loading of more items when scrolled to the bottom
        final controller = Provider.of<HomeController>(context, listen: false);
        if (!controller.isLoading && controller.hasMore) {
          controller.loadTodos();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            child: Column(
              children: [
                CustomTextField(
                  controller: _todoController,
                  hintText: AppTexts.addTodo,
                ),
                SizedBox(
                  height: Dimensions.paddingSizeDefault,
                ),
                CustomButton(
                  isLoading: false,
                  title: AppTexts.add,
                  onTap: () {
                    Provider.of<HomeController>(context, listen: false)
                        .addTodo(_todoController.text.trim(), 1);
                  },
                )
              ],
            ),
          ),
        );
      }),
      body: Consumer<HomeController>(builder: (context, homeController, child) {
        return ListView.builder(
            controller: _scrollController,
            itemCount: homeController.todos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(128.0),
                child: Text(homeController.todos[index].todo),
              );
            });
      }),
    );
  }
}
