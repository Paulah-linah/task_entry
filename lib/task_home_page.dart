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
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSelectionMode = false;
  final List<int> _selectedTasks = [];

  String _formatSelectedDate() {
    if (_selectedDate == null) return 'Select Due Date';
    return 'Due Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}';
  }

  String _formatSelectedStartTime(BuildContext context) {
    if (_startTime == null) return 'Select Start Time';
    return 'Start Time: ${_startTime!.format(context)}';
  }

  String _formatSelectedEndTime(BuildContext context) {
    if (_endTime == null) return 'Select End Time';
    return 'End Time: ${_endTime!.format(context)}';
  }

  @override
  void initState() {
    super.initState();
  }

  // Function to add a task to the list
  void _addTask() {
    if (_titleController.text.isNotEmpty &&
        _descController.text.isNotEmpty &&
        _selectedDate != null &&
        _startTime != null &&
        _endTime != null) {
      
      // Combine _selectedDate with _startTime and _endTime
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final newTask = Task(
        title: _titleController.text,
        description: _descController.text,
        dueDate: _selectedDate!,
        startTime: startDateTime,
        endTime: endDateTime,
        priority: _selectedPriority,
      );

      setState(() {
        widget.taskManager.addTask(newTask);
        _titleController.clear();
        _descController.clear();
        _selectedDate = null;
        _startTime = null;
        _endTime = null;
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

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTasks.clear();
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

  // Function to select a time
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
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

  // Get counts for tasks
  int _getTotalTasks() {
    return widget.taskManager.tasks.length;
  }

  int _getTotalCompletedTasks() {
    return widget.taskManager.tasks.where((task) => task.isCompleted).length;
  }

  int _getTotalIncompleteTasks() {
    return widget.taskManager.tasks.where((task) => !task.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.taskManager.tasks;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _exitSelectionMode,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedTasks,
                ),
              ]
            : [],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create task',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Task Description',
                        prefixIcon: Icon(Icons.subject),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.event),
                            label: Text(_formatSelectedDate()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => _selectTime(context, true),
                            icon: const Icon(Icons.schedule),
                            label: Text(_formatSelectedStartTime(context)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => _selectTime(context, false),
                            icon: const Icon(Icons.timelapse),
                            label: Text(_formatSelectedEndTime(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Priority>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.flag),
                      ),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _addTask,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Task'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Chip(
                          label: Text('Total: ${_getTotalTasks()}'),
                          avatar: const Icon(Icons.list_alt, size: 18),
                        ),
                        Chip(
                          label: Text('Completed: ${_getTotalCompletedTasks()}'),
                          avatar: Icon(Icons.check_circle, size: 18, color: colorScheme.primary),
                        ),
                        Chip(
                          label: Text('Incomplete: ${_getTotalIncompleteTasks()}'),
                          avatar: Icon(Icons.radio_button_unchecked, size: 18, color: colorScheme.tertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Your tasks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_isSelectionMode)
                  Text(
                    '${_selectedTasks.length} selected',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text('No tasks available'),
                ),
              )
            else
              ...List.generate(tasks.length, (index) {
                final task = tasks[index];
                final isSelected = _selectedTasks.contains(index);
                final priorityColor = _getPriorityColor(task.priority);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    color: isSelected ? colorScheme.secondaryContainer : null,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleTaskSelection(index);
                        } else {
                          _toggleTaskCompletion(task);
                        }
                      },
                      onLongPress: () {
                        if (!_isSelectionMode) {
                          setState(() {
                            _isSelectionMode = true;
                            _selectedTasks.add(index);
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 6, right: 12),
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                decoration: task.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                        ),
                                      ),
                                      if (_isSelectionMode)
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (_) => _toggleTaskSelection(index),
                                        )
                                      else
                                        Checkbox(
                                          value: task.isCompleted,
                                          onChanged: (_) => _toggleTaskCompletion(task),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    task.description,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text(
                                          'Due ${DateFormat('dd-MM-yyyy').format(task.dueDate)}',
                                        ),
                                      ),
                                      Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text(
                                          'Start ${DateFormat.jm().format(task.startTime)}',
                                        ),
                                      ),
                                      Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text(
                                          'End ${DateFormat.jm().format(task.endTime)}',
                                        ),
                                      ),
                                      Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text(
                                          task.priority.toString().split('.').last,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete',
                              onPressed: () => _deleteTask(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
