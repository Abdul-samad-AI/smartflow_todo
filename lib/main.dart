import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/task_list_screen.dart';

void main() {
  runApp(const SmartFlowApp());
}

class SmartFlowApp extends StatelessWidget {
  const SmartFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const TaskListScreen(),
    );
  }
}
