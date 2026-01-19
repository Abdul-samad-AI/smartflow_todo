import 'package:flutter/material.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFlow Tasks'),
      ),
      body: const Center(
        child: Text(
          'No tasks yet 👀\nTap + to add one',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
         onPressed: () {
            Navigator.push(
             context,
            MaterialPageRoute(
                builder: (_) => const AddTaskScreen(),
      ),
    );
  },
  child: const Icon(Icons.add),
),
    );
  }
}
