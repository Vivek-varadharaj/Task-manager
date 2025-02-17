import 'dart:convert';

import 'package:task_manager_app/api/api_provider.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/helper/database_helper.dart';
import 'package:task_manager_app/util/app_constants.dart';

class HomeRepository {
  final ApiClient apiClient;
  DatabaseHelper helper;

  HomeRepository({required this.apiClient, required this.helper});

  Future<TodoResponse> fetchTodos(Map<String, dynamic> body) async {
    try {
      final response =
          await apiClient.getData(AppConstants.getTodosApi, query: body);

      if (response.statusCode == 200) {
        return TodoResponse.fromJson(response.body);
      } else {
        throw Exception(response.body['message'] ?? "Fetching todos failed");
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<void> addTodo(String todoText, int userId) async {
  try {
    final response = await apiClient.postData(
      AppConstants.addTodoApi,
      {
        "todo": todoText,
        "completed": false,
        "userId": userId,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final newTodo = Todo.fromJson(response.body);
      helper.insertTasks(newTodo);
   
    } else {
      throw Exception(response.body['message'] ?? "Failed to add todo");
    }
  } catch (e) {
    print("Error adding todo: $e");
    rethrow;
  }
}

}
