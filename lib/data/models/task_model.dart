import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 1)
enum TaskDifficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  normal,
  @HiveField(2)
  hard,
}

@HiveType(typeId: 2)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final TaskPriority priority;

  @HiveField(4)
  final TaskDifficulty difficulty;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
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

  //  Used when toggling completion
  TaskModel copyWith({bool? isCompleted}) {
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

  //  FIRESTORE → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.name,
        'difficulty': difficulty.name,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  //  JSON → FIRESTORE
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: TaskPriority.values
          .firstWhere((e) => e.name == json['priority']),
      difficulty: TaskDifficulty.values
          .firstWhere((e) => e.name == json['difficulty']),
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
