import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class TimerWidget extends StatefulWidget {
  final int seconds;

  const TimerWidget({Key? key, required this.seconds}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  late int _remainingSeconds;
  bool _isRunning = false;
  bool _isCompleted = false;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() async {
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });
    // Play sound (ensure you have a sound file or handle error gracefully)
    // For MVP/Vibe mode, we'll try to use a system sound or just log/vibrate if possible.
    // Since we don't have a file, just_audio might need a url or asset.
    // We'll skip actual asset playing to avoid crash if file missing, 
    // unless user provided one. We'll just print for now as requested by user "vibe code".
    debugPrint("Timer Completed! Ding!"); 
  }

  String get _timerString {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isCompleted ? "Done!" : _timerString,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: _isCompleted ? Colors.green : Theme.of(context).primaryColor,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        if (!_isCompleted)
          if (!_isRunning && _remainingSeconds == widget.seconds)
            ElevatedButton.icon(
              onPressed: _startTimer,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text("Start Timer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          else if (_isRunning)
            OutlinedButton.icon(
              onPressed: () {
                _timer?.cancel();
                setState(() {
                  _isRunning = false;
                });
              },
              icon: const Icon(Icons.pause_rounded),
              label: const Text("Pause"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            )
          else // Paused or Resume?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startTimer,
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
                  onPressed: () {
                    setState(() {
                      _remainingSeconds = widget.seconds;
                      _isRunning = false;
                      _isCompleted = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text("Reset"),
                ),
              ],
            )
        else
          TextButton.icon(
            onPressed: () {
              setState(() {
                _remainingSeconds = widget.seconds;
                _isRunning = false;
                _isCompleted = false;
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Restart Timer"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }
}
