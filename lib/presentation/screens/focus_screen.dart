import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/focus/pomodoro_provider.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _pickFocusTime(BuildContext context, WidgetRef ref) async {
    int selectedMinutes = 25;
    final controller = FixedExtentScrollController(initialItem: 4); // 25 min

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: SizedBox(
          height: 320,
          child: Column(
            children: [
              const SizedBox(height: 12),

              // drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Set Focus Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // ⏱️ ANDROID STYLE WHEEL PICKER
              SizedBox(
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // highlight bar
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    ListWheelScrollView.useDelegate(
                      controller: controller,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        selectedMinutes = (index + 1) * 5;
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 24, // up to 120 min
                        builder: (context, index) {
                          final value = (index + 1) * 5;
                          return Center(
                            child: Text(
                              '$value min',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: controller.selectedItem == index
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                    : Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // SET BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(pomodoroProvider.notifier)
                        .setFocusDuration(selectedMinutes);
                    Navigator.pop(context);
                  },
                  child: const Text('Set Time'),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.phase == PomodoroPhase.focus ? 'FOCUS' : 'BREAK',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // ⏱️ Set focus time
            TextButton.icon(
              onPressed:
                  state.isRunning ? null : () => _pickFocusTime(context, ref),
              icon: const Icon(Icons.schedule),
              label: const Text('Set Focus Time'),
            ),

            const SizedBox(height: 16),

            Text(
              _formatTime(state.remainingSeconds),
              style: const TextStyle(fontSize: 48),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: notifier.start,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: notifier.pause,
                  child: const Text('Pause'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: notifier.reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
