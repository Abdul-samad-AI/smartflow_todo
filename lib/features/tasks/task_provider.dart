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
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await TaskRepository.updateTask(updated);
    state = TaskRepository.getTasks();
  }

  void refresh() {
    state = TaskRepository.getTasks();
  }
}

final taskProvider =
    StateNotifierProvider<TaskNotifier, List<TaskModel>>(
  (ref) => TaskNotifier(),
);
