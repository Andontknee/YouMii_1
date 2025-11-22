// lib/screens/sessions/meditation_session.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/meditation_model.dart';

class MeditationSessionScreen extends StatefulWidget {
  final MeditationType type;
  final int minutes;

  const MeditationSessionScreen({super.key, required this.type, required this.minutes});

  @override
  State<MeditationSessionScreen> createState() => _MeditationSessionScreenState();
}

class _MeditationSessionScreenState extends State<MeditationSessionScreen> {
  Timer? _mainTimer;
  Timer? _scriptTimer;

  int _secondsRemaining = 0;
  int _totalSeconds = 0;
  int _currentScriptIndex = 0;
  bool _isPaused = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.minutes * 60;
    _secondsRemaining = _totalSeconds;
    _startSession();
  }

  void _startSession() {
    // 1. Main Countdown Timer
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _finishSession();
        }
      });
    });

    // 2. Script Cycling Timer
    // Calculate how long to show each line based on total duration
    // We keep the text changing slowly to be relaxing.
    // Minimum 10 seconds per line, or distribute evenly if long session.
    int scriptInterval = (_totalSeconds / widget.type.guideScripts.length).floor();
    if (scriptInterval < 8) scriptInterval = 8; // Minimum read time

    _scriptTimer = Timer.periodic(Duration(seconds: scriptInterval), (timer) {
      if (_isPaused) return;

      setState(() {
        // Loop through scripts, but stop at the last one
        if (_currentScriptIndex < widget.type.guideScripts.length - 1) {
          _currentScriptIndex++;
        }
      });
    });
  }

  void _finishSession() {
    _mainTimer?.cancel();
    _scriptTimer?.cancel();
    setState(() {
      _isFinished = true;
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    _scriptTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark, immersive background using the meditation type's color theme but very dark
      backgroundColor: Color.lerp(Colors.black, widget.type.color, 0.1),
      body: SafeArea(
        child: _isFinished ? _buildFinishedView() : _buildActiveView(),
      ),
    );
  }

  Widget _buildActiveView() {
    return Stack(
      children: [
        // 1. Ambient Background Glow (Optional, centered circle)
        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.type.color.withOpacity(0.1),
                  blurRadius: 100,
                  spreadRadius: 50,
                )
              ],
            ),
          ),
        ),

        // 2. Main Content
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // The Guided Text (Animated Switcher for smooth fade)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1500),
                child: Text(
                  widget.type.guideScripts[_currentScriptIndex],
                  key: ValueKey<int>(_currentScriptIndex), // Key ensures animation triggers
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(),

              // Timer Display
              Text(
                _formatTime(_secondsRemaining),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(_isPaused ? Icons.play_circle_filled : Icons.pause_circle_filled,
                        size: 60, color: Colors.white),
                    onPressed: _togglePause,
                  ),
                  // Placeholder for music button (disabled for now)
                  const IconButton(
                    icon: Icon(Icons.music_note, color: Colors.white24),
                    onPressed: null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinishedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.type.icon, size: 80, color: widget.type.color),
            const SizedBox(height: 24),
            const Text(
              "Session Complete",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "You have taken a moment for yourself.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.type.color,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Done", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}