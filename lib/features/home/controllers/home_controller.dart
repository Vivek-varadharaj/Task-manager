import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:task_manager_app/common/models/response_model.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/features/home/domain/repositories/home_repository.dart';

class HomeController extends ChangeNotifier {
  final HomeRepository homeRepository;

  List<Todo> todos = [];
  List<Todo> localTodo = [];
  int total = 0;
  int skip = 0;
  int limit = 15;
  bool isLoading = false;
  bool isOfflineLoading = false;
  bool isButtonLoading = false;
  bool hasMore = true;

  HomeController({required this.homeRepository});

  Future<void> loadTodos() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    try {
      TodoResponse response = await homeRepository
          .fetchTodos({"skip": skip.toString(), "limit": limit.toString()});

      if (response.todos.isNotEmpty) {
        todos.addAll(response.todos);
        skip = skip + 1;
        total = response.total;
      } else {
        hasMore = false;
      }
    } catch (e) {
      print('Error loading todos: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOfflineTodos() async {
    isOfflineLoading = true;
    notifyListeners();
    try {
      localTodo = await homeRepository.fetchTodosFromLocalDatabase();
    } catch (e) {
      print(e);
    } finally {
      isOfflineLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(String todoText, int userId) async {
    isButtonLoading = true;
    notifyListeners();
    try {
      final newTodo = await homeRepository.addTodo(todoText, userId);
      if (newTodo != null) {
        localTodo.insert(0, newTodo);
        notifyListeners();
      }
    } catch (e) {
      print("Error adding todo: $e");
    } finally {
      isButtonLoading = false;
      notifyListeners();
    }
  }

  Future<void> editTodo(String todoText, int completed, int todoId) async {
    try {
      final newTodo = await homeRepository.editTodo(
        todoId,
        todoText,
        completed,
      );
      if (newTodo != null) {
        localTodo.removeWhere(
          (element) => element.id == todoId,
        );
        localTodo.insert(0, newTodo);
        notifyListeners();
      }
    } catch (e) {
      print("Error editing todo: $e");
    }
  }

  Future<ResponseModel> deleteTodo(int todoId) async {
    try {
      final deleted = await homeRepository.deleteTodo(
        todoId,
      );

      if (deleted) {
        localTodo.removeWhere(
          (element) => element.id == todoId,
        );
      }

      notifyListeners();
      return ResponseModel(deleted, "");
    } catch (e) {
      print("Error deleting todo: $e");
      return ResponseModel(false, e.toString());
    }
  }
}
