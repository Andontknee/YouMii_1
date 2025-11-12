// lib/screens/home/yoga_session.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/yoga_model.dart';

class YogaSession extends StatefulWidget {
  final YogaSessionData sessionData;
  const YogaSession({super.key, required this.sessionData});

  @override
  State<YogaSession> createState() => _YogaSessionState();
}

class _YogaSessionState extends State<YogaSession> {
  // A flattened list of all steps from all poses
  late List<YogaStep> _allSteps;
  late List<String> _poseTitles; // To show which pose we are on

  int _currentStepIndex = 0;
  Timer? _timer;
  int _currentDuration = 0;
  bool _isSessionActive = false;

  @override
  void initState() {
    super.initState();
    // Flatten the list of steps
    _allSteps = widget.sessionData.poses.expand((pose) => pose.steps).toList();
    // Create a corresponding list of pose titles for each step
    _poseTitles = widget.sessionData.poses.expand((pose) {
      return List.generate(pose.steps.length, (_) => pose.title);
    }).toList();
    _currentDuration = _allSteps[_currentStepIndex].durationSeconds;
  }

  void _startTimer() {
    setState(() { _isSessionActive = true; });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }

      setState(() {
        if (_currentDuration < 1) {
          timer.cancel();
          setState(() { _isSessionActive = false; });
        } else {
          _currentDuration--;
        }
      });
    });
  }

  void _moveToNextStep() {
    if (_currentStepIndex < _allSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _currentDuration = _allSteps[_currentStepIndex].durationSeconds;
        _isSessionActive = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.sessionData.title} Completed!')),
      );
      Navigator.pop(context);
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStep = _allSteps[_currentStepIndex];
    final currentPoseTitle = _poseTitles[_currentStepIndex];
    final totalSteps = _allSteps.length;
    final isLastStep = _currentStepIndex == totalSteps - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionData.title, style: theme.appBarTheme.titleTextStyle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentStepIndex + 1) / totalSteps,
                    backgroundColor: Colors.grey[800],
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Step ${_currentStepIndex + 1} of $totalSteps • $currentPoseTitle',
                    style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    currentStep.instruction,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: [
                  const SizedBox(height: 48),
                  Text(
                    _formatDuration(_currentDuration),
                    style: theme.textTheme.displayLarge!.copyWith(
                      fontSize: 80,
                      fontWeight: FontWeight.w200,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _isSessionActive ? null : (_currentDuration > 0 ? _startTimer : _moveToNextStep),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: _isSessionActive ? Colors.grey[700] : theme.primaryColor,
                    ),
                    child: Text(
                      _currentDuration > 0 ? 'START NOW' : (isLastStep ? 'FINISH SESSION' : 'NEXT STEP'),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _timer?.cancel();
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