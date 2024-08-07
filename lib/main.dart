import 'package:flutter/material.dart';
import 'task_home_page.dart';

void main() {
  runApp(TaskEntryApp());
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
