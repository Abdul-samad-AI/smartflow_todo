import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class FirestoreTaskService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _taskRef =>
      _firestore.collection('users').doc(_uid).collection('tasks');

  Future<void> uploadTask(TaskModel task) async {
    await _taskRef.doc(task.id).set(task.toJson());
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskRef.doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _taskRef.doc(taskId).delete();
  }

  Future<List<TaskModel>> fetchTasks() async {
    final snapshot = await _taskRef.get();
    return snapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
