import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'features/auth/auth_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'core/theme/app_theme.dart';
import 'data/models/task_model.dart';
import 'presentation/screens/task_list_screen.dart';
import 'firebase_options.dart';


/// 🔔 Local Notifications Plugin
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🟡 1. Initialize Hive (Offline Storage)
  await Hive.initFlutter();
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskDifficultyAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox<TaskModel>('tasksBox');

  // 🔔 2. Initialize Local Notifications
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const notificationSettings = InitializationSettings(
    android: androidSettings,
  );

  await notificationsPlugin.initialize(notificationSettings);

  // 🔥 3. Initialize Firebase (STEP 6.4 CORE)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  

  // 🚀 4. Run App with Riverpod
  runApp(
    const ProviderScope(
      child: SmartFlowApp(),
    ),
  );
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
      home: Consumer(
        builder: (context, ref, _) {
          final authState = ref.watch(authStateProvider);
      
          return authState.when(
            data: (user) {
              if (user == null) {
                return const LoginScreen();
              }
              return const TaskListScreen();
            },
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Scaffold(
              body: Center(child: Text('Something went wrong')),
            ),
          );
        },
      ),
    );
  }
}
