import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_task_screen.dart';
import '../../data/models/task_model.dart';
import '../../features/tasks/task_provider.dart';

enum SortType { time, priority, completed }

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.redAccent;
      case TaskPriority.medium:
        return Colors.orangeAccent;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

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
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) {
                      ref
                          .read(taskProvider.notifier)
                          .toggleComplete(task);
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.isCompleted
                          ? Colors.grey
                          : _priorityColor(task.priority),
                    ),
                  ),
                  subtitle: Text(
                    '${task.priority.name.toUpperCase()} • ${task.difficulty.name.toUpperCase()}',
                  ),
                );
              },
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
