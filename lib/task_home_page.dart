import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import to format dates
import 'task.dart';
import 'task_notifier.dart'; // Import TaskNotifier
import 'task_manager.dart'; // Import TaskManager

class TaskHomePage extends StatefulWidget {
  final TaskManager taskManager;

  // Constructor to accept TaskManager
  TaskHomePage({required this.taskManager});

  @override
  TaskHomePageState createState() => TaskHomePageState();
}

class TaskHomePageState extends State<TaskHomePage> with TaskNotifier {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  Priority _selectedPriority = Priority.Medium;
  DateTime? _selectedDate;
  bool _isSelectionMode = false;
  final List<int> _selectedTasks = [];

  @override
  void initState() {
    super.initState();
    // Initialize or load tasks if necessary
    // widget.taskManager.loadTasks(); // Uncomment if there's a loadTasks method
  }

  // Function to add a task to the list
  void _addTask() {
    if (_titleController.text.isNotEmpty &&
        _descController.text.isNotEmpty &&
        _selectedDate != null) {
      final newTask = Task(
        title: _titleController.text,
        description: _descController.text,
        dueDate: _selectedDate!,
        priority: _selectedPriority,
      );
      setState(() {
        widget.taskManager.addTask(newTask);
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
      widget.taskManager.toggleTaskCompletion(task);
      if (task.isCompleted) {
        logCompletion(task); // Log task completion using the TaskNotifier mixin
      }
    });
  }

  // Function to delete a task
  void _deleteTask(int index) {
    setState(() {
      widget.taskManager.deleteTask(index);
    });
  }

  // Function to delete selected tasks
  void _deleteSelectedTasks() {
    setState(() {
      widget.taskManager.deleteSelectedTasks(_selectedTasks);
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
    final tasks = widget.taskManager.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Entry App'),
        centerTitle: true,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Task Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: Text(_selectedDate == null
                            ? 'Select Due Date'
                            : 'Due Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 222, 23, 159),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 222, 23, 159),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Total Tasks: ${widget.taskManager.totalTasks}'),
                Text('Completed Tasks: ${widget.taskManager.completedTasks}'),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No tasks added yet.'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
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
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          color: isSelected
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.white,
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.description),
                                Text('Due: ${DateFormat('dd-MM-yyyy').format(task.dueDate)}'),
                                Text(
                                  'Priority: ${task.priority.toString().split('.').last}',
                                  style: TextStyle(color: _getPriorityColor(task.priority)),
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
                                    color: task.isCompleted ? Colors.green : Colors.red,
                                  ),
                                  onPressed: () => _toggleTaskCompletion(task),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
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
          if (_isSelectionMode)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _deleteSelectedTasks,
                child: const Text('Delete Selected Tasks'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
