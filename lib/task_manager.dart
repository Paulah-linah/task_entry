import 'task.dart';

class TaskManager {
  final List<Task> _tasks = [];
  int _totalTasks = 0; // Track total number of tasks
  int _completedTasks = 0; // Track number of completed tasks

  List<Task> get tasks => _tasks;
  int get totalTasks => _totalTasks;
  int get completedTasks => _completedTasks;

  void addTask(Task task) {
    _tasks.add(task);
    _totalTasks++;
    if (task.isCompleted) {
      _completedTasks++;
    }
    _tasks.sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }

  void deleteTask(int index) {
    final task = _tasks.removeAt(index);
    _totalTasks--;
    if (task.isCompleted) {
      _completedTasks--;
    }
  }

  void toggleTaskCompletion(Task task) {
    if (task.isCompleted) {
      _completedTasks--;
    } else {
      _completedTasks++;
    }
    task.isCompleted = !task.isCompleted;
  }

  void deleteSelectedTasks(List<int> selectedTasks) {
    selectedTasks.sort((a, b) => b.compareTo(a));
    for (int index in selectedTasks) {
      final task = _tasks.removeAt(index);
      _totalTasks--;
      if (task.isCompleted) {
        _completedTasks--;
      }
    }
  }
}
