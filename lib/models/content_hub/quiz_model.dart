// lib/models/content_hub/quiz_model.dart

import 'package:flutter/material.dart';

class QuizOption {
  final String text;
  final String value; // e.g., "Analytical", "Intuitive"

  QuizOption(this.text, this.value);
}

class QuizQuestion {
  final String question;
  final List<QuizOption> options;

  QuizQuestion({required this.question, required this.options});
}

class QuizResult {
  final String trait;
  final String title;
  final String description;

  QuizResult({required this.trait, required this.title, required this.description});
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final List<QuizQuestion> questions;
  final List<QuizResult> results;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.questions,
    required this.results,
  });

  // --- STATIC DATA (The Content you requested) ---
  static List<Quiz> get allQuizzes => [
    Quiz(
      id: 'decision_style',
      title: 'Decision Compass',
      description: 'Discover how you navigate choices to reduce overthinking.',
      color: const Color(0xFFA4A5F5), // Periwinkle
      icon: Icons.explore_outlined,
      results: [
        QuizResult(trait: 'Analytical', title: 'The Strategist', description: 'You value logic and details. Your strength is accuracy, but be careful of analysis paralysis.'),
        QuizResult(trait: 'Intuitive', title: 'The Gut-Truster', description: 'You value feelings and speed. Your strength is decisiveness, but remember to check the facts.'),
        QuizResult(trait: 'Collaborative', title: 'The Gatherer', description: 'You value harmony and input. Your strength is building consensus, but don\'t lose your own voice.'),
      ],
      questions: [
        QuizQuestion(
          question: "You need to buy a new phone. What is your first move?",
          options: [
            QuizOption("I read reviews and compare specs for hours.", "Analytical"),
            QuizOption("I buy the one that 'feels' right when I hold it.", "Intuitive"),
            QuizOption("I ask my friends what they use.", "Collaborative"),
          ],
        ),
        QuizQuestion(
          question: "A friend invites you on a last-minute trip. You:",
          options: [
            QuizOption("Check my budget and calendar before saying yes.", "Analytical"),
            QuizOption("Say yes immediately! Excitement leads the way.", "Intuitive"),
            QuizOption("See who else is going first.", "Collaborative"),
          ],
        ),
        QuizQuestion(
          question: "You have a tough problem at work/school. You:",
          options: [
            QuizOption("Break it down into a list of pros and cons.", "Analytical"),
            QuizOption("Sleep on it and trust the answer will come.", "Intuitive"),
            QuizOption("Call a meeting to brainstorm.", "Collaborative"),
          ],
        ),
      ],
    ),
    Quiz(
      id: 'social_battery',
      title: 'Social Battery',
      description: 'Understand how you react to social friction and pressure.',
      color: const Color(0xFFF5B8D5), // Soft Pink
      icon: Icons.battery_charging_full,
      results: [
        QuizResult(trait: 'Adaptable', title: 'The Flow Maker', description: 'You roll with the punches. You are great in a crisis, but ensure you set boundaries.'),
        QuizResult(trait: 'Cautious', title: 'The Planner', description: 'You value certainty. You prevent disasters, but may struggle when things go off-script.'),
        QuizResult(trait: 'Empathetic', title: 'The Heart', description: 'You prioritize others\' feelings. You are the glue of the group, but remember to recharge yourself.'),
      ],
      questions: [
        QuizQuestion(
          question: "You organize a picnic. An hour before, it starts pouring rain.",
          options: [
            QuizOption("It's fine! Let's build a fort inside instead.", "Adaptable"),
            QuizOption("I check three weather apps to see exactly when it stops.", "Cautious"),
            QuizOption("I text everyone immediately to ask what *they* want to do.", "Empathetic"),
          ],
        ),
        QuizQuestion(
          question: "You order a coffee with oat milk, but they give you regular milk.",
          options: [
            QuizOption("Joke about it with the barista and get a new one.", "Adaptable"),
            QuizOption("Wonder if I mumbled when I ordered it.", "Cautious"),
            QuizOption("Drink it anyway; I don't want to be a bother.", "Empathetic"),
          ],
        ),
        QuizQuestion(
          question: "You find a wallet on the street with cash inside. No ID.",
          options: [
            QuizOption("Donate the cash to a charity box nearby.", "Adaptable"),
            QuizOption("Look around for cameras or witnesses.", "Cautious"),
            QuizOption("Wait there for a while to see if anyone comes looking.", "Empathetic"),
          ],
        ),
      ],
    ),
  ];
}