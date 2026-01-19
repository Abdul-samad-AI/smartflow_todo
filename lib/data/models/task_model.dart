enum TaskPriority { low, medium, high }
enum TaskDifficulty { easy, normal, hard }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskDifficulty difficulty;
  final DateTime createdAt;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.difficulty,
    required this.createdAt,
    this.isCompleted = false,
  });

  TaskModel copyWith({
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      priority: priority,
      difficulty: difficulty,
      createdAt: createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
