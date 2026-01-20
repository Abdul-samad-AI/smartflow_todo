import '../../data/models/task_model.dart';


/// ANALYTICS DATA MODEL
class FocusAnalytics {
  // EXISTING (used by UI)
  final int completed;
  final int highPriority;
  final int hardTasks;
  final String insight;

  // NEW (future-ready, optional UI use)
  final double focusConsistency; // 0.0 → 1.0
  final String workStyle; // Deep Worker / Balanced / Light Tasker
  final int weeklyMomentum; // -1 decline | 0 stable | +1 improving

  const FocusAnalytics({
    required this.completed,
    required this.highPriority,
    required this.hardTasks,
    required this.insight,

    // New fields (safe defaults)
    this.focusConsistency = 0.0,
    this.workStyle = 'Unknown',
    this.weeklyMomentum = 0,
  });
}

/// ANALYTICS ENGINE

class FocusAnalyticsService {
  static FocusAnalytics calculate(List<TaskModel> tasks) {
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    final int highPriority = completedTasks
        .where((t) => t.priority == TaskPriority.high)
        .length;

    final int hardTasks = completedTasks
        .where((t) => t.difficulty == TaskDifficulty.hard)
        .length;


    // 1️ FOCUS CONSISTENCY
    // Ratio of completed vs total tasks
    final double focusConsistency =
        tasks.isEmpty ? 0.0 : completedTasks.length / tasks.length;


    // 2️ WORK STYLE CLASSIFICATION

    final String workStyle;
    if (hardTasks >= 3) {
      workStyle = 'Deep Worker 🧠';
    } else if (highPriority >= 3) {
      workStyle = 'Impact Focused 🔥';
    } else if (completedTasks.length >= 3) {
      workStyle = 'Consistent Executor ✅';
    } else {
      workStyle = 'Light Tasker 🌱';
    }

    // 3️ WEEKLY MOMENTUM (SIMPLE HEURISTIC)

    final int recentTasks = completedTasks.where((task) {
      final diff = DateTime.now().difference(task.createdAt).inDays;
      return diff <= 7;
    }).length;

    final int weeklyMomentum;
    if (recentTasks >= 5) {
      weeklyMomentum = 1; // improving
    } else if (recentTasks >= 2) {
      weeklyMomentum = 0; // stable
    } else {
      weeklyMomentum = -1; // declining
    }

    // 4️ SMART INSIGHT (UPGRADED)

    final String insight;
    if (hardTasks >= 3 && focusConsistency >= 0.6) {
      insight = '🧠 You thrive in deep, challenging work';
    } else if (weeklyMomentum == 1) {
      insight = '📈 Your productivity is improving this week';
    } else if (focusConsistency >= 0.5) {
      insight = '👍 Strong consistency — keep the rhythm';
    } else if (completedTasks.isNotEmpty) {
      insight = '⚡ Momentum starts with small wins';
    } else {
      insight = '🚀 Start with one easy task to build flow';
    }


    // FINAL OBJECT (BACKWARD SAFE)

    return FocusAnalytics(
      completed: completedTasks.length,
      highPriority: highPriority,
      hardTasks: hardTasks,
      insight: insight,
      focusConsistency: focusConsistency,
      workStyle: workStyle,
      weeklyMomentum: weeklyMomentum,
    );
  }
}
