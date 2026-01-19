import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

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
      home: const Scaffold(
        body: Center(
          child: Text(
            'SmartFlow 🚀',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
