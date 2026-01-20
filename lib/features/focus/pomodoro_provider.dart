import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';

enum PomodoroPhase { focus, breakTime }

class PomodoroState {
  final PomodoroPhase phase;
  final int remainingSeconds;
  final int focusDuration; // in seconds
  final bool isRunning;

  const PomodoroState({
    required this.phase,
    required this.remainingSeconds,
    required this.focusDuration,
    required this.isRunning,
  });

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? remainingSeconds,
    int? focusDuration,
    bool? isRunning,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      focusDuration: focusDuration ?? this.focusDuration,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  PomodoroNotifier()
      : super(const PomodoroState(
          phase: PomodoroPhase.focus,
          focusDuration: 25 * 60,
          remainingSeconds: 25 * 60,
          isRunning: false,
        ));

  Timer? _timer;

  //  Notification helper
  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'focus_channel',
      'Focus Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }

  //  ANDROID-LIKE MANUAL TIME SET
  void setFocusDuration(int minutes) {
    if (state.isRunning) return;

    final seconds = minutes * 60;
    state = state.copyWith(
      focusDuration: seconds,
      remainingSeconds: seconds,
    );
  }

  //  START TIMER
  void start() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _onSessionComplete();
      } else {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      }
    });
  }

  //  PAUSE TIMER
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  //  RESET TIMER
  void reset() {
    _timer?.cancel();
    state = PomodoroState(
      phase: PomodoroPhase.focus,
      focusDuration: state.focusDuration,
      remainingSeconds: state.focusDuration,
      isRunning: false,
    );
  }

  //  SESSION SWITCH LOGIC + NOTIFICATION
  void _onSessionComplete() async {
    _timer?.cancel();

    if (state.phase == PomodoroPhase.focus) {
      await _showNotification(
        'Focus Complete 🎉',
        'Great job! Time for a short break.',
      );

      state = const PomodoroState(
        phase: PomodoroPhase.breakTime,
        remainingSeconds: 5 * 60,
        focusDuration: 0,
        isRunning: false,
      );
    } else {
      await _showNotification(
        'Break Over ⏰',
        'Ready for another focus session?',
      );

      final nextFocus =
          state.focusDuration == 0 ? 25 * 60 : state.focusDuration;

      state = PomodoroState(
        phase: PomodoroPhase.focus,
        focusDuration: nextFocus,
        remainingSeconds: nextFocus,
        isRunning: false,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider =
    StateNotifierProvider<PomodoroNotifier, PomodoroState>(
  (ref) => PomodoroNotifier(),
);
