import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

class TimerWidget extends StatefulWidget {
  final String timerId;
  final int seconds;

  const TimerWidget({
    Key? key,
    required this.timerId,
    required this.seconds,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize timer state in provider if not exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false)
          .initializeTimer(widget.timerId, widget.seconds);
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, provider, child) {
        final state = provider.getTimer(widget.timerId);

        // Fallback UI if state not ready (though init should be fast)
        if (state == null) {
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }

        final progress = state.initialSeconds > 0
            ? state.remainingSeconds / state.initialSeconds
            : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Progress Line Overlay (Circular)
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: state.isCompleted ? Colors.green : Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  state.isCompleted ? "Done!" : _formatTime(state.remainingSeconds),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: state.isCompleted
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                        letterSpacing: 2,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!state.isCompleted)
              if (!state.isRunning && state.remainingSeconds == state.initialSeconds)
                ElevatedButton.icon(
                  onPressed: () => provider.startTimer(widget.timerId),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text("Start Timer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              else if (state.isRunning)
                OutlinedButton.icon(
                  onPressed: () => provider.pauseTimer(widget.timerId),
                  icon: const Icon(Icons.pause_rounded),
                  label: const Text("Pause"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                )
              else // Paused
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => provider.startTimer(widget.timerId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.play_arrow_rounded),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () => provider.resetTimer(widget.timerId),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: const Text("Reset"),
                    ),
                  ],
                )
            else
              TextButton.icon(
                onPressed: () => provider.resetTimer(widget.timerId),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Restart Timer"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
          ],
        );
      },
    );
  }
}
