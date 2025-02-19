
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/api/api_provider.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/helper/database_helper.dart';
import 'package:task_manager_app/util/app_constants.dart';
import 'package:task_manager_app/util/app_texts.dart';

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

  Future<List<Todo>> fetchTodosFromLocalDatabase() async {
    try {
      final response = await helper.getTasks();
      log(response.toString());

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Todo?> addTodo(String todoText, int userId, String description,
      TodoPriority priority, DateTime dueDate) async {
    Todo? todo;
    try {
      final prefs = await SharedPreferences.getInstance();
      int? id = prefs.getInt(AppTexts.todoId);
      final response = await apiClient.postData(
        AppConstants.addTodoApi,
        {
          "todo": todoText,
          "completed": 0,
          "userId": userId,
          "id": (id ?? 0) + 1
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        todo = Todo.fromJson({
          "todo": todoText,
          "completed": 0,
          "userId": userId,
          "id": (id ?? 0) + 1,
          "description": description,
          "dueDate": dueDate.toString(),
          "priority": priority.toInt()
        });
        await helper.insertTasks(todo);
        await saveId((id ?? 0) + 1);
      } else {
        throw Exception(response.body['message'] ?? "Failed to add todo");
      }
      return todo;
    } catch (e) {
      print("Error adding todo: $e");
      rethrow;
    }
  }

  Future<Todo?> editTodo(Todo todo) async {
    try {
      final response = await apiClient.putData(
        "${AppConstants.editTodoApi}${todo.id}",
        todo.toJson(sendId: false),
      );

      if (response.statusCode == 200 || response.statusCode == 200) {
        await helper.updateTask(todo);
      } else {
        throw Exception(response.body['message'] ?? "Failed to update todo");
      }
      return todo;
    } catch (e) {
      print("Error updating todo: $e");
      rethrow;
    }
  }

  Future<bool> deleteTodo(int todoId) async {
    try {
      final response =
          await apiClient.deleteData("${AppConstants.editTodoApi}$todoId");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await helper.deleteTask(todoId);
        return true;
      } else {
        throw Exception(response.body['message'] ?? "Failed to delete todo");
      }
    } catch (e) {
      print("Error deleting todo: $e");
      rethrow;
    }
  }

  Future<void> saveId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppTexts.todoId, id);
  }

  Future<int?> getId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(
      AppTexts.todoId,
    );
  }
}
