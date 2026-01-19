import 'package:flutter/material.dart';
import 'add_task_screen.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    tasks = TaskRepository.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFlow Tasks'),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet 👀\nTap + to add one',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(
                    '${task.priority.name.toUpperCase()} • ${task.difficulty.name.toUpperCase()}',
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTaskScreen(),
            ),
          );

          if (result == true) {
            setState(() {
              tasks = TaskRepository.getTasks();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
