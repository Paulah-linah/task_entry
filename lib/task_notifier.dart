import 'task.dart';

// Mixin to log task completion
mixin TaskNotifier {
  void logCompletion(Task task) {
    print("Task '${task.title}' is completed.");
  }
}
