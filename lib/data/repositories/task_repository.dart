import '../models/task_model.dart';

class TaskRepository {
  static final List<TaskModel> _tasks = [];

  static List<TaskModel> getTasks() {
    return _tasks;
  }

  static void addTask(TaskModel task) {
    _tasks.add(task);
  }
}
