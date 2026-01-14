enum Priority { High, Medium, Low }

// Base class for Task with required properties
class Task {
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime startTime;  // Start time of the task
  final DateTime endTime;    // End time of the task
  final Priority priority;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.startTime,
    required this.endTime,
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
    required DateTime startTime,  // Start time passed to super
    required DateTime endTime,    // End time passed to super
    required Priority priority,
  }) : super(
          title: title,
          description: description,
          dueDate: dueDate,
          startTime: startTime,
          endTime: endTime,
          priority: priority,
        );
}
