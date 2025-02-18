enum TodoPriority { low, medium, high }

class Todo {
  final int id;
  final String todo;
  final int completed;
  final int userId;
  final int dateAdded;
  final String? description;
  final int? dueDate;
  final bool? remindMe;
  final TodoPriority? priority;

  Todo({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
    required this.dateAdded,
    this.description,
    this.dueDate,
    this.remindMe,
    this.priority,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todo: json['todo'],
      completed: json['completed'] == true ? 1 : 0,
      userId: json['userId'],
      dateAdded: json['dateAdded'] ?? DateTime.now().millisecondsSinceEpoch,
      description: json['description'],
      dueDate: json['dueDate'],
      remindMe: json['remindMe'],
      priority: json['priority'] != null
          ? TodoPriority.values[json['priority']]
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
      'dateAdded': dateAdded,
      if (description != null) 'description': description,
      if (dueDate != null) 'dueDate': dueDate,
      if (remindMe != null) 'remindMe': remindMe! ? 1 : 0,
      if (priority != null) 'priority': priority!.index,
    };
  }
}

class TodoResponse {
  final List<Todo> todos;
  final int total;
  final int skip;
  final int limit;

  TodoResponse({
    required this.todos,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory TodoResponse.fromJson(Map<String, dynamic> json) {
    return TodoResponse(
      todos: List<Todo>.from(
        json['todos'].map((item) => Todo.fromJson(item)),
      ),
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todos': todos.map((todo) => todo.toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }
}
