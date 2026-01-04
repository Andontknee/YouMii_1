// lib/screens/sessions/yoga_session.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/yoga_model.dart';

class YogaSession extends StatefulWidget {
  final YogaPose pose; // FIX: Accept only one pose
  const YogaSession({super.key, required this.pose});

  @override
  State<YogaSession> createState() => _YogaSessionState();
}

class _YogaSessionState extends State<YogaSession> {
  final FlutterTts _flutterTts = FlutterTts();

  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;
  bool _isPoseComplete = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.pose.durationSeconds;
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
    });

    _flutterTts.speak("Begin.");

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          // --- TIMER FINISHED ---
          timer.cancel();
          _isTimerRunning = false;
          _isPoseComplete = true;
          _flutterTts.speak("Pose complete. Great job.");
        }
      });
    });
  }

  void _stopAndExit() {
    _timer?.cancel();
    _flutterTts.stop();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.pose.title),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: _stopAndExit,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          children: [
            // --- MAIN CONTENT CARD ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    )
                  ],
                  // Visual cue: Green border when complete
                  border: _isPoseComplete ? Border.all(color: Colors.green, width: 3) : null,
                ),
                child: Column(
                  children: [
                    // 1. IMAGE AREA
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: Image.asset(
                            widget.pose.imageAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Icon(Icons.self_improvement, size: 80, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),

                    // 2. TEXT & TIMER AREA
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  widget.pose.title,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                // Scrollable description
                                SizedBox(
                                  height: 80,
                                  child: SingleChildScrollView(
                                    child: Text(
                                      widget.pose.description,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium!.copyWith(color: Colors.grey[700], height: 1.4),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // --- CIRCULAR TIMER ---
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: _secondsRemaining / widget.pose.durationSeconds,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey[200],
                                    color: _isPoseComplete ? Colors.green : theme.primaryColor,
                                  ),
                                ),
                                Text(
                                  _isPoseComplete ? "Done" : _formatTime(_secondsRemaining),
                                  style: theme.textTheme.headlineMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _isPoseComplete ? Colors.green : theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- BOTTOM BUTTONS ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _isPoseComplete
                  ? ElevatedButton.icon(
                onPressed: _stopAndExit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text("Finish Session", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              )
                  : ElevatedButton(
                onPressed: _isTimerRunning ? null : _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTimerRunning ? Colors.grey[300] : theme.primaryColor,
                ),
                child: Text(
                  _isTimerRunning ? "Session in Progress..." : "Start Session",
                  style: TextStyle(fontSize: 18, color: _isTimerRunning ? Colors.grey : Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (!_isTimerRunning && !_isPoseComplete)
              TextButton(
                onPressed: _stopAndExit,
                child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
              ),
            if (_isTimerRunning)
              const SizedBox(height: 48), // Spacer
          ],
        ),
      ),
    );
  }
}