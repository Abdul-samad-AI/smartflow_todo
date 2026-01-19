import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_task_screen.dart';
import '../../data/models/task_model.dart';
import '../../features/tasks/task_provider.dart';
import '../../features/analytics/productivity_service.dart';


enum SortType { time, priority, completed }

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  SortType _currentSort = SortType.time;
  bool _ascending = false;

  List<TaskModel> _sortedTasks(List<TaskModel> tasks) {
    final sorted = List<TaskModel>.from(tasks);

    switch (_currentSort) {
      case SortType.time:
        sorted.sort((a, b) => _ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;

      case SortType.priority:
        sorted.sort((a, b) => _ascending
            ? a.priority.index.compareTo(b.priority.index)
            : b.priority.index.compareTo(a.priority.index));
        break;

      case SortType.completed:
        sorted.sort((a, b) => _ascending
            ? a.isCompleted.toString().compareTo(b.isCompleted.toString())
            : b.isCompleted.toString().compareTo(a.isCompleted.toString()));
        break;
    }

    return sorted;
  }

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
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final sortedTasks = _sortedTasks(tasks);
    final score = ProductivityService.calculateDailyScore(tasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFlow Tasks'),
        actions: [
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _currentSort = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortType.time,
                child: Text('Sort by Time'),
              ),
              PopupMenuItem(
                value: SortType.priority,
                child: Text('Sort by Priority'),
              ),
              PopupMenuItem(
                value: SortType.completed,
                child: Text('Sort by Completed'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _ascending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            onPressed: () {
              setState(() {
                _ascending = !_ascending;
              });
            },
          ),
        ],
      ),
      body: Column(
  children: [
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today’s Productivity Score',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: score / 100,
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Text(
            '$score / 100',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    ),
    Expanded(
      child: tasks.isEmpty
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
                    ),
                  ),
                  subtitle: Text(
                    '${task.priority.name.toUpperCase()} • ${task.difficulty.name.toUpperCase()}',
                  ),
                );
              },
            ),
    ),
  ],
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
