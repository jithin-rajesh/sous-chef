import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    if (_isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          "Done!",
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }

    if (!_isRunning && _remainingSeconds == widget.seconds) {
        // Initial State
        return ElevatedButton.icon(
            onPressed: _startTimer,
            icon: const Icon(Icons.timer),
            label: Text("Start Timer (${_timerString})"),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
        );
    }

    // Running or Paused (Counting down)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _timerString,
        style: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}
