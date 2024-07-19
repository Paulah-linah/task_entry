import 'package:flutter/material.dart';

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

// Stateful widget to manage the state of the task list
class TaskHomePage extends StatefulWidget {
  @override
  _TaskHomePageState createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final List<String> _tasks = []; // List to store tasks
  final TextEditingController _controller =
      TextEditingController(); // Controller for the TextField

  // Function to add a task to the list
  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(_controller.text);
        _controller.clear();
      });
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
            // TextField for task input
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter task',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // ElevatedButton to add the task
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 222, 23, 159), // Background color
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
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(_tasks[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _tasks.removeAt(index);
                                });
                              },
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
