enum Priority { High, Medium, Low }

// Base class for Task with required properties
class Task {
  final String title;
  final String description;
  final DateTime dueDate;
  final Priority priority;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });
}

// Subclass of Task for future time-related functionalities
class TimedTask extends Task {
  TimedTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required Priority priority,
  }) : super(
          title: title,
          description: description,
          dueDate: dueDate,
          priority: priority,
        );
}
