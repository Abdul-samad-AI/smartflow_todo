import '../../data/models/task_model.dart';

class ProductivityService {
  static int calculateDailyScore(List<TaskModel> tasks) {
    int score = 0;

    for (final task in tasks) {
      if (!task.isCompleted) continue;

      int priorityScore;
      switch (task.priority) {
        case TaskPriority.low:
          priorityScore = 1;
          break;
        case TaskPriority.medium:
          priorityScore = 2;
          break;
        case TaskPriority.high:
          priorityScore = 3;
          break;
      }

      int difficultyScore;
      switch (task.difficulty) {
        case TaskDifficulty.easy:
          difficultyScore = 1;
          break;
        case TaskDifficulty.normal:
          difficultyScore = 2;
          break;
        case TaskDifficulty.hard:
          difficultyScore = 3;
          break;
      }

      final completedToday =
          task.createdAt.day == DateTime.now().day &&
          task.createdAt.month == DateTime.now().month &&
          task.createdAt.year == DateTime.now().year;

      final completionFactor = completedToday ? 2 : 1;

      score += (priorityScore + difficultyScore) * completionFactor;
    }

    return score.clamp(0, 100);
  }
}
