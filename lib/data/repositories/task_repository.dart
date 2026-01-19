import '../models/task_model.dart';

class TaskRepository {
  static final List<TaskModel> _tasks = [];

  static List<TaskModel> getTasks() {
    return _tasks;
  }

  static void addTask(TaskModel task) {
    _tasks.add(task);
  }

  static void updateTask(TaskModel updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
  }
}
