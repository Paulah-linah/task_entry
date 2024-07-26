import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import to format dates

void main() {
  runApp(TaskEntryApp());
}

// Enum to define task priority
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

// Mixin to log task completion
mixin TaskNotifier {
  void logCompletion(Task task) {
    print("Task '${task.title}' is completed.");
  }
}

// Main entry point of the app
class TaskEntryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Disable the debug banner
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskHomePage(),
    );
  }
}

// Stateful widget to manage the state of the task list
class TaskHomePage extends StatefulWidget {
  @override
  _TaskHomePageState createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> with TaskNotifier {
  final List<Task> _tasks = []; // List to store tasks
  final TextEditingController _titleController =
      TextEditingController(); // Controller for title input
  final TextEditingController _descController =
      TextEditingController(); // Controller for description input
  Priority _selectedPriority = Priority.Medium; // Default priority
  DateTime? _selectedDate; // Selected due date

  // Function to add a task to the list
  void _addTask() {
    if (_titleController.text.isNotEmpty &&
        _descController.text.isNotEmpty &&
        _selectedDate != null) {
      setState(() {
        _tasks.add(Task(
          title: _titleController.text,
          description: _descController.text,
          dueDate: _selectedDate!,
          priority: _selectedPriority,
        ));
        _titleController.clear();
        _descController.clear();
        _selectedDate = null;
        _selectedPriority = Priority.Medium;
      });
    }
  }

  // Function to handle task completion
  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      if (task.isCompleted) {
        logCompletion(task);
      }
    });
  }

  // Function to delete a task
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  // Function to select a due date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function to compare task priority
  int _comparePriority(Task a, Task b) {
    return a.priority.index.compareTo(b.priority.index);
  }

  // Function to get priority color
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.High:
        return Colors.red;
      case Priority.Medium:
        return Colors.orange;
      case Priority.Low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Entry App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // TextField for task title input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // TextField for task description input
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Date picker for due date
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(_selectedDate == null
                        ? 'Select Due Date'
                        : 'Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                          255, 222, 23, 159), // Pink background color
                      foregroundColor: Colors.white, // Text color
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Dropdown for task priority
            DropdownButton<Priority>(
              value: _selectedPriority,
              onChanged: (Priority? newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
              items: Priority.values
                  .map<DropdownMenuItem<Priority>>((Priority value) {
                return DropdownMenuItem<Priority>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            // ElevatedButton to add the task
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 222, 23, 159), // Pink background color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            SizedBox(height: 10),
            // Expanded ListView to display tasks
            Expanded(
              child: _tasks.isEmpty
                  ? Center(child: Text('No tasks added yet.'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.description),
                                Text(
                                    'Due: ${DateFormat('yyyy-MM-dd').format(task.dueDate)}'),
                                Text(
                                  'Priority: ${task.priority.toString().split('.').last}',
                                  style: TextStyle(
                                      color: _getPriorityColor(task.priority)),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    task.isCompleted
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: task.isCompleted
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  onPressed: () => _toggleTaskCompletion(task),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTask(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
