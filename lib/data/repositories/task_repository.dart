import 'package:hive/hive.dart';
import '../models/task_model.dart';

class TaskRepository {
  static final Box<TaskModel> _taskBox =
      Hive.box<TaskModel>('tasksBox');

  // Read all tasks (local)
  static List<TaskModel> getTasks() {
    return _taskBox.values.toList();
  }

  // Add task
  static Future<void> addTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  // Update task
  static Future<void> updateTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  // Delete task by id
  static Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
  }

  // Replace all tasks (cloud -> local sync)
  static Future<void> replaceAll(List<TaskModel> tasks) async {
    await _taskBox.clear();
    for (final task in tasks) {
      await _taskBox.put(task.id, task);
    }
  }

  // Clear all tasks (used on logout)
  static Future<void> clearAll() async {
    await _taskBox.clear();
  }
}
