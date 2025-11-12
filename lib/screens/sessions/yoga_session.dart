// lib/screens/sessions/yoga_session.dart

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
  int _currentPoseIndex = 0;
  int _currentStepIndex = 0;
  Timer? _timer;
  int _currentDuration = 0;
  bool _isSessionActive = false;
  bool _isPaused = false;
  bool _isPreparationPhase = true;
  int _preparationTime = 5; // Reduced to 5 seconds for testing

  YogaPose get _currentPose => widget.sessionData.poses[_currentPoseIndex];
  YogaStep get _currentStep => _currentPose.steps[_currentStepIndex];

  @override
  void initState() {
    super.initState();
    _startPreparationPhase();
  }

  // FIX: Always cancel previous timer before starting new one
  void _startPreparationPhase() {
    _cancelTimer(); // Cancel any existing timer
    setState(() {
      _isPreparationPhase = true;
      _currentDuration = _preparationTime;
      _isSessionActive = false;
      _isPaused = false;
    });
    _startTimer(_moveToExercisePhase);
  }

  void _moveToExercisePhase() {
    _cancelTimer(); // Cancel any existing timer
    setState(() {
      _isPreparationPhase = false;
      _currentDuration = _currentStep.durationSeconds;
      _isSessionActive = false;
      _isPaused = false;
    });
    _startTimer(_autoAdvanceToNextStep);
  }

  // FIX: Proper timer management
  void _startTimer(VoidCallback onComplete) {
    _cancelTimer(); // Cancel any existing timer first

    setState(() {
      _isSessionActive = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        _cancelTimer();
        return;
      }

      setState(() {
        if (_currentDuration > 0) {
          _currentDuration--;
        } else {
          _cancelTimer(); // Properly cancel when done
          _isSessionActive = false;
          onComplete();
        }
      });
    });
  }

  // FIX: Single method to cancel timer
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _pauseTimer() {
    _cancelTimer();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    if (_isPreparationPhase) {
      _startTimer(_moveToExercisePhase);
    } else {
      _startTimer(_autoAdvanceToNextStep);
    }
  }

  void _autoAdvanceToNextStep() {
    _cancelTimer(); // Cancel timer before navigation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _moveToNextStep();
      }
    });
  }

  void _moveToNextStep() {
    _cancelTimer(); // Cancel timer before state changes

    if (_currentStepIndex < _currentPose.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _startPreparationPhase();
    } else if (_currentPoseIndex < widget.sessionData.poses.length - 1) {
      setState(() {
        _currentPoseIndex++;
        _currentStepIndex = 0;
      });
      _startPreparationPhase();
    } else {
      _completeSession();
    }
  }

  void _moveToPreviousStep() {
    _cancelTimer(); // Cancel timer before navigation

    if (!_isPreparationPhase && _currentDuration == _currentStep.durationSeconds) {
      setState(() {
        _isPreparationPhase = true;
        _currentDuration = _preparationTime;
      });
    } else if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
      _startPreparationPhase();
    } else if (_currentPoseIndex > 0) {
      setState(() {
        _currentPoseIndex--;
        _currentStepIndex = _currentPose.steps.length - 1;
      });
      _startPreparationPhase();
    } else {
      _startPreparationPhase();
    }
  }

  void _completeSession() {
    _cancelTimer();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Complete!'),
          content: Text('Congratulations! You completed "${widget.sessionData.title}"'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Finish'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  double get _overallProgress {
    final totalSteps = widget.sessionData.poses.fold(0, (sum, pose) => sum + pose.steps.length);
    int completedSteps = 0;

    for (int i = 0; i < _currentPoseIndex; i++) {
      completedSteps += widget.sessionData.poses[i].steps.length;
    }
    completedSteps += _currentStepIndex;

    return totalSteps > 0 ? completedSteps / totalSteps : 0;
  }

  @override
  void dispose() {
    _cancelTimer(); // Use our cancel method
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPoses = widget.sessionData.poses.length;
    final totalStepsInCurrentPose = _currentPose.steps.length;
    final isFirstStep = _currentPoseIndex == 0 && _currentStepIndex == 0;
    final isLastStep = _currentPoseIndex == widget.sessionData.poses.length - 1 &&
        _currentStepIndex == _currentPose.steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionData.title, style: theme.appBarTheme.titleTextStyle),
        actions: [
          if (_isSessionActive || _isPaused)
            IconButton(
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: _isPaused ? _resumeTimer : _pauseTimer,
              tooltip: _isPaused ? 'Resume' : 'Pause',
            ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _overallProgress,
            backgroundColor: Colors.grey[800],
            color: theme.primaryColor,
            minHeight: 4,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        'Pose ${_currentPoseIndex + 1} of $totalPoses',
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentPose.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Step ${_currentStepIndex + 1} of $totalStepsInCurrentPose',
                        style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _currentStep.instruction,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _formatDuration(_currentDuration),
                              style: theme.textTheme.displayLarge!.copyWith(
                                fontSize: 64,
                                fontWeight: FontWeight.w300,
                                color: _isPreparationPhase ? Colors.orange : theme.primaryColor,
                              ),
                            ),
                            if (_isPreparationPhase)
                              Text(
                                'Preparation - Starting in...',
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: Colors.orange,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isSessionActive && !_isPaused && !_isPreparationPhase)
                        ElevatedButton(
                          onPressed: () => _startTimer(_autoAdvanceToNextStep),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: theme.primaryColor,
                          ),
                          child: const Text(
                            'START STEP',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),

                      if ((_isSessionActive || _isPaused) && !_isPreparationPhase) ...[
                        Row(
                          children: [
                            if (!isFirstStep)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _moveToPreviousStep,
                                  child: const Text('PREVIOUS'),
                                ),
                              ),
                            if (!isFirstStep) const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _moveToNextStep,
                                child: Text(isLastStep ? 'FINISH' : 'SKIP TO NEXT'),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (_isPreparationPhase && !_isSessionActive && !_isPaused)
                        ElevatedButton(
                          onPressed: _moveToExercisePhase,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text(
                            'START NOW',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),

                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _showEndSessionDialog,
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
        ],
      ),
    );
  }

  void _showEndSessionDialog() {
    _cancelTimer(); // Cancel timer when ending session
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Are you sure you want to end this yoga session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _cancelTimer();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}