import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import to format dates
import 'task.dart';
import 'task_notifier.dart';

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
  bool _isSelectionMode = false; // Flag to track selection mode
  final List<int> _selectedTasks = []; // List to store selected task indices

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
        _tasks.sort((a, b) => a.priority.index.compareTo(b.priority.index));
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

  // Function to delete selected tasks
  void _deleteSelectedTasks() {
    setState(() {
      _selectedTasks.sort((a, b) => b.compareTo(a));
      for (int index in _selectedTasks) {
        _tasks.removeAt(index);
      }
      _selectedTasks.clear();
      _isSelectionMode = false;
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

  // Function to handle task selection
  void _toggleTaskSelection(int index) {
    setState(() {
      if (_selectedTasks.contains(index)) {
        _selectedTasks.remove(index);
        if (_selectedTasks.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedTasks.add(index);
        _isSelectionMode = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Entry App'),
        centerTitle: true,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = false;
                      _selectedTasks.clear();
                    });
                  },
                ),
              ]
            : [],
      ),
      body: Column(
        children: <Widget>[
          // TextField for task title input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
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
                    backgroundColor: Color.fromARGB(
                        255, 222, 23, 159), // Pink background color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          // Expanded ListView to display tasks
          Expanded(
            child: _tasks.isEmpty
                ? Center(child: Text('No tasks added yet.'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      final isSelected = _selectedTasks.contains(index);
                      return GestureDetector(
                        onLongPress: () {
                          _toggleTaskSelection(index);
                        },
                        onTap: () {
                          if (_isSelectionMode) {
                            _toggleTaskSelection(index);
                          }
                        },
                        child: Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          color: isSelected
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.white,
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
                                  onPressed: () =>
                                      _toggleTaskCompletion(task),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTask(index),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Delete button for selected tasks
          if (_isSelectionMode)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _deleteSelectedTasks,
                child: Text('Delete Selected Tasks'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red background color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
