import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add_task_screen.dart';
import 'focus_screen.dart';

import '../../data/models/task_model.dart';
import '../../features/tasks/task_provider.dart';
import '../../features/analytics/mood_model.dart';
import '../../features/analytics/mood_provider.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  // 🎨 Priority text color (existing behavior)
  Color _priorityTextColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.redAccent;
      case TaskPriority.medium:
        return Colors.orangeAccent;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  // 🧠 Check if task matches current mood
  bool _matchesMood(TaskModel task, UserMood mood) {
    switch (mood) {
      case UserMood.tired:
        return task.priority == TaskPriority.low &&
            task.difficulty == TaskDifficulty.easy;
      case UserMood.normal:
        return task.priority == TaskPriority.medium &&
            task.difficulty == TaskDifficulty.normal;
      case UserMood.energetic:
        return task.priority == TaskPriority.high &&
            task.difficulty == TaskDifficulty.hard;
    }
  }

  // 🎨 Soft background highlight based on mood
  Color _moodHighlightColor(UserMood mood, BuildContext context) {
    switch (mood) {
      case UserMood.tired:
        return Colors.green.withOpacity(0.12);
      case UserMood.normal:
        return Colors.blue.withOpacity(0.12);
      case UserMood.energetic:
        return Colors.red.withOpacity(0.12);
    }
  }

  // 🔁 Reorder tasks: matching mood tasks first
  List<TaskModel> _reorderTasksByMood(
    List<TaskModel> tasks,
    UserMood mood,
  ) {
    final matching =
        tasks.where((t) => _matchesMood(t, mood)).toList();
    final others =
        tasks.where((t) => !_matchesMood(t, mood)).toList();

    return [...matching, ...others];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(moodProvider);
    final tasks = ref.watch(taskProvider);

    final reorderedTasks = _reorderTasksByMood(tasks, mood);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFlow Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FocusScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 🙂 MOOD SELECTOR
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text('😴 Tired'),
                  selected: mood == UserMood.tired,
                  onSelected: (_) => ref
                      .read(moodProvider.notifier)
                      .state = UserMood.tired,
                ),
                ChoiceChip(
                  label: const Text('🙂 Normal'),
                  selected: mood == UserMood.normal,
                  onSelected: (_) => ref
                      .read(moodProvider.notifier)
                      .state = UserMood.normal,
                ),
                ChoiceChip(
                  label: const Text('🚀 Energetic'),
                  selected: mood == UserMood.energetic,
                  onSelected: (_) => ref
                      .read(moodProvider.notifier)
                      .state = UserMood.energetic,
                ),
              ],
            ),
          ),

          const Divider(),

          // 📋 TASK LIST
          Expanded(
            child: reorderedTasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet 👀\nTap + to add one',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: reorderedTasks.length,
                    itemBuilder: (context, index) {
                      final task = reorderedTasks[index];
                      final matchesMood =
                          _matchesMood(task, mood);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: matchesMood
                              ? _moodHighlightColor(mood, context)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
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
                                  : _priorityTextColor(task.priority),
                            ),
                          ),
                          subtitle: Text(
                            '${task.priority.name.toUpperCase()} • ${task.difficulty.name.toUpperCase()}',
                          ),
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
