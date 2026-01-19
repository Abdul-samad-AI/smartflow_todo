import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

class TaskNotifier extends StateNotifier<List<TaskModel>> {
  TaskNotifier() : super(TaskRepository.getTasks());

  Future<void> addTask(TaskModel task) async {
    await TaskRepository.addTask(task);
    state = TaskRepository.getTasks();
  }

  Future<void> toggleComplete(TaskModel task) async {
    // Optimistic UI update
    state = [
      for (final t in state)
        if (t.id == task.id)
          t.copyWith(isCompleted: !t.isCompleted)
        else
          t
    ];

    // Persist to Hive
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await TaskRepository.updateTask(updated);
    }


  void refresh() {
    state = TaskRepository.getTasks();
  }
}

final taskProvider =
    StateNotifierProvider<TaskNotifier, List<TaskModel>>(
  (ref) => TaskNotifier(),
);
