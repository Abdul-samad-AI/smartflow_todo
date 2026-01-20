import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/analytics/focus_analytics_service.dart';
import 'add_task_screen.dart';
import 'focus_screen.dart';
import '../../data/models/task_model.dart';
import '../../features/tasks/task_provider.dart';
import '../../features/analytics/mood_model.dart';
import '../../features/analytics/mood_provider.dart';
import '../../features/analytics/productivity_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


enum SortType { time, priority, completed }

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() =>
      _TaskListScreenState();
}

class _TaskListScreenState
    extends ConsumerState<TaskListScreen> {
  SortType _sortType = SortType.time;
  bool _ascending = false;

  // ---------- HELPERS ----------

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

  Color _moodHighlightColor(UserMood mood) {
    switch (mood) {
      case UserMood.tired:
        return Colors.green.withOpacity(0.12);
      case UserMood.normal:
        return Colors.blue.withOpacity(0.12);
      case UserMood.energetic:
        return Colors.red.withOpacity(0.12);
    }
  }

  List<TaskModel> _applySorting(
    List<TaskModel> tasks,
    UserMood mood,
  ) {
    // 1️ Mood-based prioritization
    final matching =
        tasks.where((t) => _matchesMood(t, mood)).toList();
    final others =
        tasks.where((t) => !_matchesMood(t, mood)).toList();

    List<TaskModel> result = [...matching, ...others];

    // 2️ Sorting
    switch (_sortType) {
      case SortType.time:
        result.sort((a, b) => _ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.priority:
        result.sort((a, b) => _ascending
            ? a.priority.index.compareTo(b.priority.index)
            : b.priority.index.compareTo(a.priority.index));
        break;
      case SortType.completed:
        result.sort((a, b) => _ascending
            ? a.isCompleted.toString().compareTo(b.isCompleted.toString())
            : b.isCompleted
                .toString()
                .compareTo(a.isCompleted.toString()));
        break;
    }

    return result;
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final mood = ref.watch(moodProvider);
    final tasks = ref.watch(taskProvider);
    final score =
        ProductivityService.calculateDailyScore(tasks);

    final visibleTasks = _applySorting(tasks, mood);

    return Scaffold(
      // ☰ SLIDING DRAWER
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Focus Dashboard',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
      
                //  DAILY SCORE CARD
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today’s Productivity',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: score / 100,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$score / 100',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
      
                const SizedBox(height: 20),
      
                //  WEEKLY INSIGHTS
                Builder(
                  builder: (context) {
                    final analytics =
                        FocusAnalyticsService.calculate(tasks);
      
                    return Card(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weekly Focus Insights',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
      
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                _InsightChip(
                                    label: 'Completed',
                                    value: analytics.completed),
                                _InsightChip(
                                    label: 'High Priority',
                                    value: analytics.highPriority),
                                _InsightChip(
                                    label: 'Hard Tasks',
                                    value: analytics.hardTasks),
                              ],
                            ),
      
                            const SizedBox(height: 16),
                            Text(
                              analytics.insight,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                      
                const Spacer(),
                //  LOGOUT BUTTON
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    // 1️ Clear local tasks
                    await ref.read(taskProvider.notifier).clearAll();
                
                    // 2️ Firebase sign out
                    await FirebaseAuth.instance.signOut();
                
                    // 3️ Close drawer
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    //  Auth state listener will auto-redirect to LoginScreen
                  },
                ),

      
                const Text(
                  'SmartFlow helps you work with your energy,\nnot against it.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),


      appBar: AppBar(
        title: const Text('SmartFlow Tasks'),
        actions: [
          //  Focus Mode
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

          //  SORT MENU (RESTORED)
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortType = value;
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
                _ascending ? Icons.arrow_upward : Icons.arrow_downward),
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
          //  MOOD SELECTOR
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

          //  TASK LIST
          Expanded(
            child: visibleTasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet 👀\nTap + to add one',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: visibleTasks.length,
                    itemBuilder: (context, index) {
                      final task = visibleTasks[index];
                      final matchesMood =
                          _matchesMood(task, mood);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: matchesMood
                              ? _moodHighlightColor(mood)
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
// slider analytics
class _InsightChip extends StatelessWidget {
  final String label;
  final int value;

  const _InsightChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
