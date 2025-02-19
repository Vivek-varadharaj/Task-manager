import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:task_manager_app/common/models/response_model.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/features/home/domain/repositories/home_repository.dart';
import 'package:task_manager_app/features/home/widgets/modal_sheet_for_edit.dart';

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
  TodoPriority priority = TodoPriority.high;
  DateTime dueDate = DateTime.now();

  late ScrollController scrollController;
  late ScrollController offlineScrollController;
  late TextEditingController todoController;
  late TextEditingController descriptionController;

  HomeController({required this.homeRepository}) {
    scrollController = ScrollController();
    offlineScrollController = ScrollController();
    todoController = TextEditingController();
    descriptionController = TextEditingController();
  }

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

  Future<ResponseModel> addTodo() async {
    isButtonLoading = true;
    notifyListeners();
    try {
      final newTodo = await homeRepository.addTodo(todoController.text.trim(),
          1, descriptionController.text.trim(), priority, dueDate);
      if (newTodo != null) {
        localTodo.insert(0, newTodo);
        notifyListeners();
        return ResponseModel(true, "Todo added successfully");
      }
      return ResponseModel(false, "failed");
    } catch (e) {
      return ResponseModel(false, e.toString());
    } finally {
      isButtonLoading = false;
      notifyListeners();
    }
  }

  Future<ResponseModel> editTodo(Todo todo, {bool isLocal = true}) async {
    isButtonLoading = true;
    notifyListeners();
    try {
      final newTodo = await homeRepository.editTodo(todo!.copyWith(
          completed: todo.completed,
          description: descriptionController.text.trim(),
          priority: priority,
          dueDate: dueDate.toString(),
          todo: todoController.text.trim()));
      if (newTodo != null) {
        if (isLocal) {
          log("if worked");
          localTodo.removeWhere(
            (element) => element.id == todo.id,
          );

          localTodo.insert(0, newTodo);
        } else {
          log("Else worked");
          todos.removeWhere(
            (element) => element.id == todo.id,
          );
          todos.insert(0, newTodo);
        }

        notifyListeners();
        return ResponseModel(true, "Todo edit successfully");
      }
      return ResponseModel(false, "Todo edit failed");
    } catch (e) {
      return ResponseModel(true, e.toString());
    } finally {
      isButtonLoading = false;
      notifyListeners();
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

  togglePriority(TodoPriority priority) {
    this.priority = priority;
    notifyListeners();
  }

  toggleDueDate(DateTime dueDate) {
    this.dueDate = dueDate;
    notifyListeners();
  }

  void clearEditFields() {
    priority = TodoPriority.high;
    dueDate = DateTime.now();
    todoController.clear();
    descriptionController.clear();
  }

  void assignValues(Todo todo) {
    priority = todo.priority ?? TodoPriority.high;
    dueDate = DateTime.parse(todo.dueDate ?? DateTime.now().toString());
    todoController.text = todo.todo;
    descriptionController.text = todo.description ?? "";
    notifyListeners();
  }

  String? validateTodo() {
    String? message;
    if (todoController.text.trim().isEmpty) {
      message = "Please enter todo";
    } else if (descriptionController.text.isEmpty) {
      message = "Please enter description";
    }
    return message;
  }

  @override
  void dispose() {
    scrollController.dispose();
    offlineScrollController.dispose();
    todoController.dispose();
    descriptionController.dispose();

    super.dispose();
  }
}
