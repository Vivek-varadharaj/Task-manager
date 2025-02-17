import 'package:flutter/material.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/features/home/domain/repositories/home_repository.dart';

class HomeController extends ChangeNotifier {
  final HomeRepository homeRepository;
  List<Todo> todos = [];
  int total = 0;
  int skip = 0;
  int limit = 5;
  bool isLoading = false;
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
}
