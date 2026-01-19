import '../../data/models/task_model.dart';
import 'mood_model.dart';

class MoodSuggestionService {
  static List<TaskModel> suggestTasks({
    required List<TaskModel> tasks,
    required UserMood mood,
  }) {
    final incompleteTasks =
        tasks.where((t) => !t.isCompleted).toList();

    switch (mood) {
      case UserMood.tired:
        return incompleteTasks.where((task) =>
            task.priority == TaskPriority.low &&
            task.difficulty == TaskDifficulty.easy).toList();

      case UserMood.normal:
        return incompleteTasks.where((task) =>
            task.priority == TaskPriority.medium &&
            task.difficulty == TaskDifficulty.normal).toList();

      case UserMood.energetic:
        return incompleteTasks.where((task) =>
            task.priority == TaskPriority.high &&
            task.difficulty == TaskDifficulty.hard).toList();
    }
  }
}
