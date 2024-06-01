import 'package:db_practice_sqlflite/models/task.dart';
import 'package:db_practice_sqlflite/services/database_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  String? _task;

  @override
  void initState() {
    super.initState();
    _refreshTasks(); // Refresh the list of tasks when the widget is initialized
  }

  Future<void> _refreshTasks() async {
    print('Refreshing tasks');
    setState(() {}); // Trigger UI update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")), // App bar with title
      body: _tasksList(), // Display the list of tasks
      floatingActionButton:
          _addTaskButton(), // Floating action button to add a new task
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Add Task"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _task = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter task...",
                  ),
                ),
                MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (_task == null || _task!.isEmpty) return;
                    _databaseService.addTask(_task!).then((_) {
                      _refreshTasks();
                      Navigator.pop(context); // Close the dialog
                    });
                  },
                  child: const Text("Add"),
                )
              ],
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _tasksList() {
    return FutureBuilder<List<Task>>(
      future: _databaseService
          .getTasks(), // Fetch the list of tasks from the database
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child:
                  CircularProgressIndicator()); // Show loading indicator while waiting for data
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
                  'Error: ${snapshot.error}')); // Show error message if there was an error
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text(
                  'No tasks available')); // Show message if no tasks are available
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Task task = snapshot.data![index];
              return ListTile(
                onLongPress: () {
                  _databaseService.deleteTask(
                    task.id,
                  );
                  setState(() {});
                },
                title: Text(
                  task.content,
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Checkbox(
                  value: task.status == 1,
                  onChanged: (value) {
                    _databaseService.updateTaskStatus(
                        task.id, value == true ? 1 : 0);
                    setState(() {});
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
