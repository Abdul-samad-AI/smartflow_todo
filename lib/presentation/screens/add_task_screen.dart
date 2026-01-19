import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  TaskDifficulty _difficulty = TaskDifficulty.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Priority
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
              ),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Difficulty
            DropdownButtonFormField<TaskDifficulty>(
              value: _difficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
              ),
              items: TaskDifficulty.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _difficulty = value!;
                });
              },
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                // Save logic comes next
                Navigator.pop(context);
              },
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
