import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/firestore_task_service.dart';

class TaskNotifier extends StateNotifier<List<TaskModel>> {
  final FirestoreTaskService _firestoreService = FirestoreTaskService();

  TaskNotifier() : super(TaskRepository.getTasks());

  // Add task (Hive + Firestore)
  Future<void> addTask(TaskModel task) async {
    // Save locally (offline-first)
    await TaskRepository.addTask(task);

    // Update UI state
    state = [...state, task];

    // Sync to Firestore
    try {
      await _firestoreService.uploadTask(task);
    } catch (_) {
      // Ignore errors to allow offline usage
    }
  }

  // Toggle completion (Hive + Firestore)
  Future<void> toggleComplete(TaskModel task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);

    // Optimistic UI update
    state = [
      for (final t in state)
        if (t.id == task.id) updated else t
    ];

    // Save locally
    await TaskRepository.updateTask(updated);

    // Sync to Firestore
    try {
      await _firestoreService.updateTask(updated);
    } catch (_) {}
  }

  // Delete task (Hive + Firestore)
  Future<void> deleteTask(TaskModel task) async {
    // Update UI
    state = state.where((t) => t.id != task.id).toList();

    // Delete locally
    await TaskRepository.deleteTask(task.id);

    // Delete from Firestore
    try {
      await _firestoreService.deleteTask(task.id);
    } catch (_) {}
  }

  // Sync tasks from Firestore to local storage
  Future<void> syncFromCloud() async {
    try {
      final cloudTasks = await _firestoreService.fetchTasks();

      // Replace local Hive data
      await TaskRepository.replaceAll(cloudTasks);

      // Update UI state
      state = cloudTasks;
    } catch (_) {
      // Keep local data if offline or error
    }
  }

  // Clear all local tasks (used on logout)
  Future<void> clearAll() async {
    await TaskRepository.clearAll();
    state = [];
  }

  // Reload tasks from local storage only
  void refresh() {
    state = TaskRepository.getTasks();
  }
}

final taskProvider =
    StateNotifierProvider<TaskNotifier, List<TaskModel>>(
  (ref) => TaskNotifier(),
);
