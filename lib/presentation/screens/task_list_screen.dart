import 'package:flutter/material.dart';
import 'add_task_screen.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

enum SortType { time, priority, completed }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<TaskModel> tasks = [];
  SortType _currentSort = SortType.time;
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    tasks = List.from(TaskRepository.getTasks());
    _applySorting();
  }

  void _applySorting() {
    setState(() {
      switch (_currentSort) {
        case SortType.time:
          tasks.sort((a, b) =>
              _ascending ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt));
          break;

        case SortType.priority:
          tasks.sort((a, b) =>
              _ascending ? a.priority.index.compareTo(b.priority.index) : b.priority.index.compareTo(a.priority.index));
          break;

        case SortType.completed:
          tasks.sort((a, b) =>
              _ascending ? a.isCompleted.toString().compareTo(b.isCompleted.toString()) : b.isCompleted.toString().compareTo(a.isCompleted.toString()));
          break;
      }
    });
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

  void _toggleComplete(TaskModel task) {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    TaskRepository.updateTask(updatedTask);
    _loadTasks();
  }

  String _sortLabel() {
    switch (_currentSort) {
      case SortType.time:
        return 'Time';
      case SortType.priority:
        return 'Priority';
      case SortType.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFlow Tasks'),
        actions: [
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              _currentSort = value;
              _applySorting();
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
            icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              _ascending = !_ascending;
              _applySorting();
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet 👀\nTap + to add one',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Sorted by ${_sortLabel()} (${_ascending ? 'Ascending' : 'Descending'})',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => _toggleComplete(task),
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
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
            _loadTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
