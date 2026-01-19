import 'package:hive/hive.dart';
import '../models/task_model.dart';

class TaskRepository {
  static final Box<TaskModel> _taskBox =
      Hive.box<TaskModel>('tasksBox');

  static List<TaskModel> getTasks() {
    return _taskBox.values.toList();
  }

  static Future<void> addTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  static Future<void> updateTask(TaskModel task) async {
    await task.save();
  }

  static Future<void> deleteTask(TaskModel task) async {
    await task.delete();
  }
}
