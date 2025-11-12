// lib/screens/home/breathing_session.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/activity_model.dart';

class BreathingSession extends StatefulWidget {
  final Activity activity;
  const BreathingSession({super.key, required this.activity});

  @override
  State<BreathingSession> createState() => _BreathingSessionState();
}

class _BreathingSessionState extends State<BreathingSession> {
  // --- SESSION STATE FOR A SINGLE-STAGE TIMER ---
  Timer? _sessionTimer; // The main timer for the whole session
  Timer? _animationTimer; // A separate timer to control the animation cycle
  int _totalDurationSeconds = 0;

  bool _isSessionActive = false;

  // Animation state
  String _animationInstruction = 'Get Ready';
  double _circleSize = 150.0;
  Color _circleColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    // The total duration is now the only one we need to track
    _totalDurationSeconds = widget.activity.totalTimeMinutes * 60;
  }

  // --- TIMER LOGIC FOR A SINGLE, CONTINUOUS SESSION ---
  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _startAnimationCycle();
    });

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_totalDurationSeconds < 1) {
          _sessionTimer?.cancel();
          _animationTimer?.cancel();
          _isSessionActive = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.activity.title} Session Completed!')),
          );
          Navigator.pop(context); // Automatically go back when done
        } else {
          _totalDurationSeconds--;
        }
      });
    });
  }

  // --- ANIMATION CYCLE LOGIC ---
  void _startAnimationCycle() {
    // A full box breathing cycle is 4 + 4 + 4 + 4 = 16 seconds
    const cycleDuration = Duration(seconds: 16);

    _animationTimer = Timer.periodic(cycleDuration, (timer) {
      if (!_isSessionActive || !mounted) {
        timer.cancel();
        return;
      }
      _runAnimationSequence();
    });
    // Run the first sequence immediately
    _runAnimationSequence();
  }

  void _runAnimationSequence() {
    // Inhale (4s)
    setState(() {
      _animationInstruction = 'Inhale...';
      _circleSize = 250.0; // Grow
      _circleColor = Theme.of(context).primaryColor;
    });

    // Hold (4s)
    Future.delayed(const Duration(seconds: 4), () {
      if (!_isSessionActive || !mounted) return;
      setState(() {
        _animationInstruction = 'Hold';
        _circleColor = Colors.orange; // Change color to indicate hold
      });
    });

    // Exhale (4s)
    Future.delayed(const Duration(seconds: 8), () {
      if (!_isSessionActive || !mounted) return;
      setState(() {
        _animationInstruction = 'Exhale...';
        _circleSize = 150.0; // Shrink
        _circleColor = Colors.blueGrey;
      });
    });

    // Hold (4s)
    Future.delayed(const Duration(seconds: 12), () {
      if (!_isSessionActive || !mounted) return;
      setState(() {
        _animationInstruction = 'Hold';
        _circleColor = Colors.grey; // Change color back
      });
    });
  }


  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.activity.title} Session', style: theme.appBarTheme.titleTextStyle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- TOP SECTION: Initial Instructions ---
              Column(
                children: [
                  Text(
                    'Box Breathing Exercise',
                    style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Follow the on-screen visual guide. Inhale as the circle grows, hold, and exhale as it shrinks.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey),
                  ),
                ],
              ),

              // --- MIDDLE SECTION: Animated Visual Guide ---
              Expanded(
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 4), // Animation duration matches the breath
                    curve: Curves.easeInOut,
                    width: _circleSize,
                    height: _circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _circleColor,
                    ),
                    child: Center(
                      child: Text(
                        _animationInstruction,
                        style: theme.textTheme.titleLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),

              // --- BOTTOM SECTION: Timer and Controls ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _formatDuration(_totalDurationSeconds),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall!.copyWith(
                      fontWeight: FontWeight.w300,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSessionActive ? null : _startSession,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: _isSessionActive ? Colors.grey[700] : theme.primaryColor,
                    ),
                    child: Text(
                      'BEGIN SESSION',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _sessionTimer?.cancel();
                      _animationTimer?.cancel();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'End Session',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}