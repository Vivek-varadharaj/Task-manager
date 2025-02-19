enum TodoPriority {
  low,
  medium,
  high;

  int toInt() => index;
  static TodoPriority fromInt(int index) => TodoPriority.values[index];
}

class Todo {
  final int id;
  final String todo;
  final int completed;
  final int userId;
  final int? dateAdded;
  final String? description;
  final String? dueDate;
  final bool? remindMe;
  final TodoPriority? priority;

  Todo({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
    this.dateAdded,
    this.description,
    this.dueDate,
    this.remindMe,
    this.priority,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todo: json['todo'],
      completed: json['completed'].runtimeType == bool
          ? json['completed'] == true
              ? 1
              : 0
          : json['completed'],
      userId: json['userId'],
      dateAdded: json['dateAdded'] ?? DateTime.now().millisecondsSinceEpoch,
      description: json['description'],
      dueDate: json['dueDate'],
      remindMe: json['remindMe'] == 1 ? true : false,
      priority: json['priority'] != null
          ? TodoPriority.values[json['priority']]
          : null,
    );
  }

  Map<String, dynamic> toJson({bool sendId = true}) {
    return {
      if (sendId) 'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
      'dateAdded': dateAdded,
      if (description != null) 'description': description,
      if (dueDate != null) 'dueDate': dueDate,
      if (remindMe != null) 'remindMe': remindMe! ? 1 : 0,
      if (priority != null) 'priority': priority!.toInt(),
    };
  }

  Todo copyWith({
    int? id,
    String? todo,
    int? completed,
    int? userId,
    int? dateAdded,
    String? description,
    String? dueDate,
    bool? remindMe,
    TodoPriority? priority,
  }) {
    return Todo(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      dateAdded: dateAdded ?? this.dateAdded,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      remindMe: remindMe ?? this.remindMe,
      priority: priority ?? this.priority,
    );
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
