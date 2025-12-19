// lib/screens/sessions/meditation_session.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart'; // Ensure flutter_tts is in pubspec.yaml
import '../../models/meditation_model.dart';

class MeditationSessionScreen extends StatefulWidget {
  final MeditationType type;
  final int minutes;

  const MeditationSessionScreen({super.key, required this.type, required this.minutes});

  @override
  State<MeditationSessionScreen> createState() => _MeditationSessionScreenState();
}

class _MeditationSessionScreenState extends State<MeditationSessionScreen> {
  // TTS
  final FlutterTts _flutterTts = FlutterTts();
  bool _isMuted = false;

  // Timers
  Timer? _mainTimer;
  Timer? _stepTimer;

  // State
  int _secondsRemaining = 0;
  int _currentStepIndex = 0;
  bool _isPaused = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.minutes * 60;
    _initTts();
    _startSession();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.4); // Slow, calming speed
  }

  void _speak(String text) async {
    if (!_isMuted && mounted) {
      await _flutterTts.speak(text);
    }
  }

  void _startSession() {
    // 1. Calculate duration per step
    // We divide total time by number of steps to pace it perfectly
    int stepDuration = (_secondsRemaining / widget.type.steps.length).floor();
    if (stepDuration < 5) stepDuration = 5; // Minimum 5 seconds per step

    // Speak first step immediately
    _speak(widget.type.steps[0]);

    // 2. Main Countdown Timer (Updates UI every second)
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _finishSession();
          }
        });
      }
    });

    // 3. Step Progression Timer (Moves to next instruction)
    _stepTimer = Timer.periodic(Duration(seconds: stepDuration), (timer) {
      if (_isPaused) return;

      if (_currentStepIndex < widget.type.steps.length - 1) {
        if (mounted) {
          setState(() {
            _currentStepIndex++;
          });
          // Speak the new step
          _speak(widget.type.steps[_currentStepIndex]);
        }
      }
    });
  }

  void _finishSession() {
    _mainTimer?.cancel();
    _stepTimer?.cancel();
    if (mounted) {
      setState(() {
        _isFinished = true;
      });
      _speak("Session complete. Have a wonderful day.");
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _flutterTts.stop();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) _flutterTts.stop();
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
    _stepTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using a soft gradient based on the meditation color
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.type.color.withOpacity(0.3), // Soft top
              const Color(0xFFF0F4F8), // Fade to white/grey
            ],
          ),
        ),
        child: SafeArea(
          child: _isFinished ? _buildFinishedView() : _buildActiveView(),
        ),
      ),
    );
  }

  Widget _buildActiveView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
              Text(widget.type.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.grey),
                onPressed: _toggleMute,
              ),
            ],
          ),

          const Spacer(flex: 1),

          // Central Visual
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: widget.type.color.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)
              ],
            ),
            child: Icon(widget.type.icon, size: 80, color: widget.type.color),
          ),

          const SizedBox(height: 40),

          // Instruction Text (Animated)
          SizedBox(
            height: 120,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: Text(
                widget.type.steps[_currentStepIndex],
                key: ValueKey<int>(_currentStepIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),

          const Spacer(flex: 1),

          // Timer
          Text(
            _formatTime(_secondsRemaining),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 24,
              fontWeight: FontWeight.w300,
              letterSpacing: 2.0,
            ),
          ),

          const SizedBox(height: 30),

          // Play/Pause
          FloatingActionButton(
            onPressed: _togglePause,
            backgroundColor: widget.type.color,
            foregroundColor: Colors.white,
            elevation: 4,
            child: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 32),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFinishedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 100, color: widget.type.color),
            const SizedBox(height: 24),
            const Text(
              "Session Complete",
              style: TextStyle(color: Colors.black87, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Take this sense of calm with you into the rest of your day.",
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