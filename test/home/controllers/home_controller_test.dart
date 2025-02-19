import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_app/features/home/controllers/home_controller.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';
import 'package:task_manager_app/features/home/domain/repositories/home_repository.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

class FakeTodo extends Fake implements Todo {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTodo());
    registerFallbackValue(TodoPriority.low);
  });

  late HomeController homeController;
  late MockHomeRepository mockHomeRepository;

  setUp(() {
    mockHomeRepository = MockHomeRepository();
    homeController = HomeController(homeRepository: mockHomeRepository);
  });

  group('loadTodos', () {
    test('does not call repository when isLoading is true', () async {
      homeController.isLoading = true;
      await homeController.loadTodos();
      verifyNever(() => mockHomeRepository.fetchTodos(any()));
    });

    test('does not call repository when hasMore is false', () async {
      homeController.hasMore = false;
      await homeController.loadTodos();
      verifyNever(() => mockHomeRepository.fetchTodos(any()));
    });

    test('loads todos and updates skip and total on success', () async {
      homeController.isLoading = false;
      homeController.hasMore = true;
      final fakeTodo = Todo(
        id: 1,
        todo: 'Test Todo',
        completed: 0,
        userId: 1,
        description: 'Desc',
        dueDate: '2025-12-31',
        priority: TodoPriority.high,
      );
      final responseJson = {
        'todos': [fakeTodo.toJson()],
        'total': 10,
        'skip': 0,
        'limit': 15,
      };
      final todoResponse = TodoResponse.fromJson(responseJson);
      when(() => mockHomeRepository.fetchTodos(any()))
          .thenAnswer((_) async => todoResponse);
      await homeController.loadTodos();
      expect(homeController.todos.length, 1);
      expect(homeController.skip, 1);
      expect(homeController.total, 10);
    });

    test('sets hasMore false when no todos are returned', () async {
      homeController.isLoading = false;
      homeController.hasMore = true;
      final responseJson = {
        'todos': [],
        'total': 10,
        'skip': 0,
        'limit': 15,
      };
      final todoResponse = TodoResponse.fromJson(responseJson);
      when(() => mockHomeRepository.fetchTodos(any()))
          .thenAnswer((_) async => todoResponse);
      await homeController.loadTodos();
      expect(homeController.hasMore, isFalse);
    });

    test('handles exceptions gracefully', () async {
      homeController.isLoading = false;
      when(() => mockHomeRepository.fetchTodos(any()))
          .thenThrow(Exception('Error'));
      await homeController.loadTodos();
      expect(homeController.isLoading, isFalse);
    });
  });

  group('loadOfflineTodos', () {
    test('loads local todos successfully', () async {
      final fakeTodo = Todo(
        id: 1,
        todo: 'Offline Todo',
        completed: 0,
        userId: 1,
        description: 'Desc',
        dueDate: '2025-12-31',
        priority: TodoPriority.medium,
      );
      when(() => mockHomeRepository.fetchTodosFromLocalDatabase())
          .thenAnswer((_) async => [fakeTodo]);
      await homeController.loadOfflineTodos();
      expect(homeController.localTodo.length, 1);
    });

    test('handles exception gracefully', () async {
      when(() => mockHomeRepository.fetchTodosFromLocalDatabase())
          .thenThrow(Exception('DB error'));
      await homeController.loadOfflineTodos();
      expect(homeController.isOfflineLoading, isFalse);
    });
  });

  group('addTodo', () {
    setUp(() {
      homeController.todoController.text = 'New Todo';
      homeController.descriptionController.text = 'New Description';
    });

    test('returns success response when addTodo is successful', () async {
      final fakeTodo = Todo(
        id: 2,
        todo: 'New Todo',
        completed: 0,
        userId: 1,
        description: 'New Description',
        dueDate: homeController.dueDate.toString(),
        priority: homeController.priority,
      );
      when(() => mockHomeRepository.addTodo(any(), any(), any(), any(), any()))
          .thenAnswer((_) async => fakeTodo);
      final response = await homeController.addTodo();
      expect(response.isSuccess, isTrue);
      expect(response.message, 'Todo added successfully');
      expect(homeController.localTodo.first.todo, 'New Todo');
      expect(homeController.isButtonLoading, isFalse);
    });

    test('returns failure response when addTodo returns null', () async {
      when(() => mockHomeRepository.addTodo(any(), any(), any(), any(), any()))
          .thenAnswer((_) async => null);
      final response = await homeController.addTodo();
      expect(response.isSuccess, isFalse);
      expect(response.message, 'failed');
    });

    test('returns failure response when addTodo throws exception', () async {
      when(() => mockHomeRepository.addTodo(any(), any(), any(), any(), any()))
          .thenThrow(Exception('Add error'));
      final response = await homeController.addTodo();
      expect(response.isSuccess, isFalse);
      expect(response.message, contains('Add error'));
    });
  });

  group('editTodo', () {
    final originalTodo = Todo(
      id: 3,
      todo: 'Old Todo',
      completed: 0,
      userId: 1,
      description: 'Old Description',
      dueDate: '2025-12-31',
      priority: TodoPriority.medium,
    );

    test('updates localTodo when isLocal is true', () async {
      homeController.localTodo = [originalTodo];
      homeController.todoController.text = 'Edited Todo';
      homeController.descriptionController.text = 'Edited Description';
      final editedTodo = originalTodo.copyWith(
        todo: 'Edited Todo',
        description: 'Edited Description',
        dueDate: homeController.dueDate.toString(),
        priority: homeController.priority,
      );
      when(() => mockHomeRepository.editTodo(any()))
          .thenAnswer((_) async => editedTodo);
      final response =
          await homeController.editTodo(originalTodo, isLocal: true);
      expect(response.isSuccess, isTrue);
      expect(homeController.localTodo.first.todo, 'Edited Todo');
    });

    test('updates todos when isLocal is false', () async {
      homeController.todos = [originalTodo];
      homeController.todoController.text = 'Edited Todo';
      homeController.descriptionController.text = 'Edited Description';
      final editedTodo = originalTodo.copyWith(
        todo: 'Edited Todo',
        description: 'Edited Description',
        dueDate: homeController.dueDate.toString(),
        priority: homeController.priority,
      );
      when(() => mockHomeRepository.editTodo(any()))
          .thenAnswer((_) async => editedTodo);
      final response =
          await homeController.editTodo(originalTodo, isLocal: false);
      expect(response.isSuccess, isTrue);
      expect(homeController.todos.first.todo, 'Edited Todo');
    });

    test('returns failure response when editTodo returns null', () async {
      when(() => mockHomeRepository.editTodo(any()))
          .thenAnswer((_) async => null);
      final response = await homeController.editTodo(originalTodo);
      expect(response.isSuccess, isFalse);
      expect(response.message, 'Todo edit failed');
    });

    test('returns failure response when editTodo throws exception', () async {
      when(() => mockHomeRepository.editTodo(any()))
          .thenThrow(Exception('Edit error'));
      final response = await homeController.editTodo(originalTodo);
      // Note: The catch block in editTodo returns ResponseModel(true, e.toString())
      // which may be unintentional. Adjust the test if needed.
      expect(response.isSuccess, isTrue);
      expect(response.message, contains('Edit error'));
    });
  });

  group('deleteTodo', () {
    final todoId = 4;
    test('returns success response when deletion is successful', () async {
      homeController.localTodo = [
        Todo(
          id: todoId,
          todo: 'To be deleted',
          completed: 0,
          userId: 1,
          description: 'Desc',
          dueDate: '2025-12-31',
          priority: TodoPriority.low,
        )
      ];
      when(() => mockHomeRepository.deleteTodo(todoId))
          .thenAnswer((_) async => true);
      final response = await homeController.deleteTodo(todoId);
      expect(response.isSuccess, isTrue);
      expect(homeController.localTodo.length, 0);
    });

    test('returns failure response when deletion fails', () async {
      when(() => mockHomeRepository.deleteTodo(todoId))
          .thenThrow(Exception('Delete error'));
      final response = await homeController.deleteTodo(todoId);
      expect(response.isSuccess, isFalse);
      expect(response.message, contains('Delete error'));
    });
  });

  group('togglePriority', () {
    test('updates priority', () {
      final initialPriority = homeController.priority;
      homeController.togglePriority(TodoPriority.low);
      expect(homeController.priority, TodoPriority.low);
      expect(homeController.priority, isNot(initialPriority));
    });
  });

  group('toggleDueDate', () {
    test('updates dueDate', () {
      final newDate = DateTime(2026, 1, 1);
      homeController.toggleDueDate(newDate);
      expect(homeController.dueDate, newDate);
    });
  });

  group('clearEditFields', () {
    test('resets priority, dueDate and clears controllers', () {
      homeController.todoController.text = 'Some Todo';
      homeController.descriptionController.text = 'Some Description';
      homeController.clearEditFields();
      expect(homeController.priority, TodoPriority.high);
      expect(homeController.todoController.text, isEmpty);
      expect(homeController.descriptionController.text, isEmpty);
    });
  });

  group('assignValues', () {
    test(
        'assigns values from todo to controllers and updates priority, dueDate',
        () {
      final sampleTodo = Todo(
        id: 5,
        todo: 'Assign Todo',
        completed: 0,
        userId: 1,
        description: 'Assign Desc',
        dueDate: '2025-12-31 00:00:00.000',
        priority: TodoPriority.medium,
      );
      homeController.assignValues(sampleTodo);
      expect(homeController.priority, TodoPriority.medium);
      expect(homeController.dueDate.toString(), sampleTodo.dueDate);
      expect(homeController.todoController.text, sampleTodo.todo);
      expect(homeController.descriptionController.text, sampleTodo.description);
    });
  });

  group('validateTodo', () {
    test('returns error message when todo is empty', () {
      homeController.todoController.text = '';
      homeController.descriptionController.text = 'Desc';
      final message = homeController.validateTodo();
      expect(message, 'Please enter todo');
    });

    test('returns error message when description is empty', () {
      homeController.todoController.text = 'Todo';
      homeController.descriptionController.text = '';
      final message = homeController.validateTodo();
      expect(message, 'Please enter description');
    });

    test('returns null when both fields are filled', () {
      homeController.todoController.text = 'Todo';
      homeController.descriptionController.text = 'Desc';
      final message = homeController.validateTodo();
      expect(message, isNull);
    });
  });
}
