// lib/screens/sessions/breathing_session.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/activity_model.dart';
import '../home/home_screen.dart'; // We need this for the MoodItem model

class BreathingSession extends StatefulWidget {
  final Activity activity;
  const BreathingSession({super.key, required this.activity});

  @override
  State<BreathingSession> createState() => _BreathingSessionState();
}

// Enum to manage the different phases of the session
enum SessionPhase { preparing, breathing, finished }

class _BreathingSessionState extends State<BreathingSession> with TickerProviderStateMixin {
  // --- SESSION STATE ---
  SessionPhase _phase = SessionPhase.preparing;
  Timer? _sessionTimer;
  Timer? _animationTimer;
  int _totalDurationSeconds = 0;

  // --- ANIMATION STATE ---
  String _instructionText = 'Get Ready...';
  // We use two colors to create a pulsing gradient effect
  Color _gradientColor1 = Colors.blueGrey.shade800;
  Color _gradientColor2 = Colors.black;
  // Controls the size of a subtle guide circle
  double _guideCircleSize = 200.0;


  @override
  void initState() {
    super.initState();
    _totalDurationSeconds = widget.activity.totalTimeMinutes * 60;
  }

  // --- TIMER & ANIMATION LOGIC ---
  void _startSession() {
    setState(() {
      _phase = SessionPhase.breathing;
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
          _phase = SessionPhase.finished; // Transition to the finished screen
        } else {
          _totalDurationSeconds--;
        }
      });
    });
  }

  void _startAnimationCycle() {
    // A full box breathing cycle is 4 (inhale) + 4 (hold) + 4 (exhale) + 4 (hold) = 16 seconds
    const cycleDuration = Duration(seconds: 16);

    _runAnimationSequence(); // Run the first sequence immediately
    _animationTimer = Timer.periodic(cycleDuration, (timer) {
      if (_phase != SessionPhase.breathing || !mounted) {
        timer.cancel();
        return;
      }
      _runAnimationSequence();
    });
  }

  void _runAnimationSequence() {
    // Inhale (4s)
    setState(() {
      _instructionText = 'Inhale Deeply';
      _gradientColor1 = Theme.of(context).primaryColor.withOpacity(0.5); // Pulse to lavender
      _guideCircleSize = 300.0; // Grow
    });

    // Hold (4s)
    Future.delayed(const Duration(seconds: 4), () {
      if (_phase != SessionPhase.breathing || !mounted) return;
      setState(() {
        _instructionText = 'Hold';
        _gradientColor2 = Colors.orange.shade900; // Pulse a warm color for hold
      });
    });

    // Exhale (4s)
    Future.delayed(const Duration(seconds: 8), () {
      if (_phase != SessionPhase.breathing || !mounted) return;
      setState(() {
        _instructionText = 'Exhale Slowly';
        _gradientColor1 = Colors.blueGrey.shade800; // Pulse back to dark
        _guideCircleSize = 200.0; // Shrink
      });
    });

    // Hold (4s)
    Future.delayed(const Duration(seconds: 12), () {
      if (_phase != SessionPhase.breathing || !mounted) return;
      setState(() {
        _instructionText = 'Hold';
        _gradientColor2 = Colors.black; // Pulse back to black
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

  // --- UI BUILDER METHODS ---
  @override
  Widget build(BuildContext context) {
    // Use a switch to build the UI based on the current session phase
    switch (_phase) {
      case SessionPhase.preparing:
        return _buildPreparationUI();
      case SessionPhase.breathing:
        return _buildBreathingUI();
      case SessionPhase.finished:
        return _buildFinishedUI();
    }
  }

  // UI for the "Get Ready" screen
  Widget _buildPreparationUI() {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.activity.title} Session'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Box Breathing',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'This technique helps calm the nervous system. When you are ready, find a comfortable position and begin.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _startSession,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('BEGIN', style: TextStyle(fontSize: 18)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI for the active breathing session
  Widget _buildBreathingUI() {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // The animated background gradient
          AnimatedContainer(
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [_gradientColor1, _gradientColor2],
                radius: 1.5,
              ),
            ),
          ),
          // The main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _instructionText,
                    style: theme.textTheme.headlineSmall!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),

                  // The subtle guide circle
                  AnimatedContainer(
                    duration: const Duration(seconds: 4),
                    curve: Curves.easeInOut,
                    width: _guideCircleSize,
                    height: _guideCircleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                  ),

                  Text(
                    _formatDuration(_totalDurationSeconds),
                    style: theme.textTheme.displayMedium!.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The "End Session" button at the bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () {
                  _sessionTimer?.cancel();
                  _animationTimer?.cancel();
                  Navigator.pop(context);
                },
                child: const Text('End Session', style: TextStyle(color: Colors.white54)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI for the post-session feedback screen
  Widget _buildFinishedUI() {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  'Session Complete',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                Text(
                  'How do you feel now?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // --- Mood emojis for feedback ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: MoodItem.allMoods.map((mood) {
                    return IconButton(
                      icon: Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                      onPressed: () {
                        // TODO: Save this post-activity mood to Firebase
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Noted! You are feeling ${mood.label}.')),
                        );
                      },
                    );
                  }).toList(),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('FINISH', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}