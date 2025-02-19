import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/api/api_provider.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/helper/database_helper.dart';
import 'package:task_manager_app/util/app_constants.dart';
import 'package:task_manager_app/util/app_texts.dart';
import 'package:task_manager_app/features/home/domain/repositories/home_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class FakeTodo extends Fake implements Todo {}

void main() {
  late HomeRepository homeRepository;
  late MockApiClient mockApiClient;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDatabaseHelper = MockDatabaseHelper();
    homeRepository =
        HomeRepository(apiClient: mockApiClient, helper: mockDatabaseHelper);
    registerFallbackValue(FakeTodo());
  });

  group('fetchTodos', () {
    test('returns TodoResponse when response is successful', () async {
      final fakeJson = {
        "todos": [
          {
            "id": 1,
            "todo": "Buy milk",
            "completed": 0,
            "userId": 123,
            "dateAdded": 1610000000000,
            "description": "Buy a gallon of milk",
            "dueDate": "2025-12-31",
            "remindMe": 1,
            "priority": 2
          },
          {
            "id": 2,
            "todo": "Send email",
            "completed": 1,
            "userId": 123,
            "dateAdded": 1610005000000,
            "description": "Send email to Bob",
            "dueDate": "2024-01-15",
            "remindMe": 0,
            "priority": 0
          }
        ],
        "total": 2,
        "skip": 0,
        "limit": 10
      };
      final apiResponse = ApiResponse(statusCode: 200, body: fakeJson);
      when(() => mockApiClient.getData(AppConstants.getTodosApi,
          query: any(named: 'query'))).thenAnswer((_) async => apiResponse);
      final result = await homeRepository.fetchTodos({'page': 1});
      expect(result.todos.length, 2);
    });

    test('throws exception when response is not successful', () async {
      final apiResponse =
          ApiResponse(statusCode: 400, body: {'message': 'Error occurred'});
      when(() => mockApiClient.getData(AppConstants.getTodosApi,
          query: any(named: 'query'))).thenAnswer((_) async => apiResponse);
      expect(() async => await homeRepository.fetchTodos({'page': 1}),
          throwsException);
    });
  });

  group('fetchTodosFromLocalDatabase', () {
    test('returns list of Todo from local database', () async {
      final fakeTodos = [
        Todo(
          id: 1,
          todo: 'Test Todo',
          completed: 0,
          userId: 1,
          description: 'Test description',
          dueDate: '2025-01-01',
          priority: TodoPriority.low,
        )
      ];
      when(() => mockDatabaseHelper.getTasks())
          .thenAnswer((_) async => fakeTodos);
      final result = await homeRepository.fetchTodosFromLocalDatabase();
      expect(result.length, 1);
    });

    test('throws exception when local database call fails', () async {
      when(() => mockDatabaseHelper.getTasks())
          .thenThrow(Exception('DB error'));
      expect(() async => await homeRepository.fetchTodosFromLocalDatabase(),
          throwsException);
    });
  });

  group('addTodo', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    final dueDate = DateTime(2025, 1, 1);
    test('returns Todo when addTodo is successful', () async {
      final apiResponse =
          ApiResponse(statusCode: 200, body: {'message': 'Todo added'});
      when(() => mockApiClient.postData(AppConstants.addTodoApi, any()))
          .thenAnswer((_) async => apiResponse);
      when(() => mockDatabaseHelper.insertTasks(any()))
          .thenAnswer((_) async => 1);
      final todo = await homeRepository.addTodo(
          'Test Todo', 1, 'Test description', TodoPriority.low, dueDate);
      expect(todo, isNotNull);
      expect(todo!.todo, 'Test Todo');
      expect(todo.completed, 0);
      expect(todo.userId, 1);
      expect(todo.description, 'Test description');
      expect(todo.dueDate, dueDate.toString());
      expect(todo.priority, TodoPriority.low);
    });

    test('throws exception when addTodo API call fails', () async {
      final apiResponse =
          ApiResponse(statusCode: 400, body: {'message': 'Failed to add todo'});
      when(() => mockApiClient.postData(AppConstants.addTodoApi, any()))
          .thenAnswer((_) async => apiResponse);
      expect(
          () async => await homeRepository.addTodo(
              'Test Todo', 1, 'Test description', TodoPriority.low, dueDate),
          throwsException);
    });
  });

  group('editTodo', () {
    test('returns Todo when editTodo is successful', () async {
      final todo = Todo(
          id: 1,
          todo: 'Updated Todo',
          completed: 0,
          userId: 1,
          description: 'Test description',
          dueDate: '2025-01-01',
          priority: TodoPriority.high);
      final apiResponse =
          ApiResponse(statusCode: 200, body: {'message': 'Updated'});
      when(() => mockApiClient.putData(
              "${AppConstants.editTodoApi}${todo.id}", any()))
          .thenAnswer((_) async => apiResponse);
      when(() => mockDatabaseHelper.updateTask(todo))
          .thenAnswer((_) async => 1);
      final result = await homeRepository.editTodo(todo);
      expect(result, isNotNull);
      expect(result?.todo, 'Updated Todo');
    });

    test('throws exception when editTodo API call fails', () async {
      final todo = Todo(
          id: 1,
          todo: 'Updated Todo',
          completed: 0,
          userId: 1,
          description: 'Test description',
          dueDate: '2025-01-01',
          priority: TodoPriority.high);
      final apiResponse = ApiResponse(
          statusCode: 400, body: {'message': 'Failed to update todo'});
      when(() => mockApiClient.putData(
              "${AppConstants.editTodoApi}${todo.id}", any()))
          .thenAnswer((_) async => apiResponse);
      expect(() async => await homeRepository.editTodo(todo), throwsException);
    });
  });

  group('deleteTodo', () {
    test('returns true when deleteTodo is successful', () async {
      const todoId = 1;
      final apiResponse =
          ApiResponse(statusCode: 200, body: {'message': 'Deleted'});
      when(() => mockApiClient.deleteData("${AppConstants.editTodoApi}$todoId"))
          .thenAnswer((_) async => apiResponse);
      when(() => mockDatabaseHelper.deleteTask(todoId))
          .thenAnswer((_) async => 1);
      final result = await homeRepository.deleteTodo(todoId);
      expect(result, isTrue);
    });

    test('throws exception when deleteTodo API call fails', () async {
      const todoId = 1;
      final apiResponse = ApiResponse(
          statusCode: 400, body: {'message': 'Failed to delete todo'});
      when(() => mockApiClient.deleteData("${AppConstants.editTodoApi}$todoId"))
          .thenAnswer((_) async => apiResponse);
      expect(
          () async => await homeRepository.deleteTodo(todoId), throwsException);
    });
  });

  group('saveId and getId', () {
    test('saveId stores the id and getId retrieves it', () async {
      SharedPreferences.setMockInitialValues({});
      await homeRepository.saveId(5);
      final prefs = await SharedPreferences.getInstance();
      final storedId = prefs.getInt(AppTexts.todoId);
      expect(storedId, 5);
      SharedPreferences.setMockInitialValues({AppTexts.todoId: 10});
      final id = await homeRepository.getId(10);
      expect(id, 10);
    });
  });
}
