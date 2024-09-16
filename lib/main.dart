import 'package:flutter/material.dart';
import 'task_home_page.dart';
import 'task_manager.dart'; // Import the TaskManager class

void main() {
  runApp(TaskEntryApp());
}

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
      home: TaskHomePage(
        taskManager: TaskManager(), // Pass TaskManager to TaskHomePage
      ),
    );
  }
}
