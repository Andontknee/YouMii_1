// lib/screens/home/quiz_screen.dart

import 'package:flutter/material.dart';
import '../../models/content_hub/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, int> _scores = {}; // Tracks scores: {"Analytical": 2, "Intuitive": 1}
  bool _isFinished = false;

  void _answerQuestion(String value) {
    // 1. Update Score
    _scores[value] = (_scores[value] ?? 0) + 1;

    // 2. Move Next
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  QuizResult _calculateResult() {
    // Find the key with the highest value
    var sortedKeys = _scores.keys.toList(growable: false)
      ..sort((k1, k2) => _scores[k2]!.compareTo(_scores[k1]!));

    String topTrait = sortedKeys.isNotEmpty ? sortedKeys.first : widget.quiz.results.first.trait;

    // Match it to a result object
    return widget.quiz.results.firstWhere(
            (r) => r.trait == topTrait,
        orElse: () => widget.quiz.results.first
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.quiz.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isFinished ? _buildResultView(theme) : _buildQuestionView(theme),
      ),
    );
  }

  Widget _buildQuestionView(ThemeData theme) {
    final question = widget.quiz.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: progress, color: widget.quiz.color, backgroundColor: Colors.grey[300], minHeight: 6, borderRadius: BorderRadius.circular(3)),
        const SizedBox(height: 10),
        Text("Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}", style: TextStyle(color: Colors.grey[600])),
        const Spacer(flex: 1),
        Text(question.question, style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const Spacer(flex: 1),
        ...question.options.map((option) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: () => _answerQuestion(option.value),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black12)),
            ),
            child: Text(option.text, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ),
        )),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildResultView(ThemeData theme) {
    final result = _calculateResult();

    return Center(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.quiz.icon, size: 60, color: widget.quiz.color),
              const SizedBox(height: 24),
              Text("You are...", style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(result.title, style: theme.textTheme.headlineMedium!.copyWith(color: widget.quiz.color, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(result.description, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: widget.quiz.color, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                child: const Text("Finish", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}