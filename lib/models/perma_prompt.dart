// lib/models/perma_prompt.dart

import 'package:flutter/material.dart';
import 'dart:math';

// Enum to define the 5 focus areas
enum PermaFocus {
  positiveEmotion, // P
  engagement,      // E
  relationships,   // R
  meaning,         // M
  accomplishment,  // A
}

class PermaPrompt {
  final PermaFocus focus;
  final String title;
  final String prompt;
  final IconData icon;

  PermaPrompt({
    required this.focus,
    required this.title,
    required this.prompt,
    required this.icon,
  });

  // A static list of prompts for the app to cycle through
  static final List<PermaPrompt> allPrompts = [
    // P - Positive Emotions (Gratitude, Joy)
    PermaPrompt(
      focus: PermaFocus.positiveEmotion,
      title: 'Gratitude',
      prompt: 'Pause now and intentionally list one small thing you are genuinely grateful for today.',
      icon: Icons.favorite_border,
    ),
    PermaPrompt(
      focus: PermaFocus.positiveEmotion,
      title: 'Joyful Moment',
      prompt: 'Recall a moment from the last 24 hours that made you genuinely smile. Savor that feeling.',
      icon: Icons.sentiment_satisfied_alt_outlined,
    ),

    // E - Engagement (Flow, Strengths)
    PermaPrompt(
      focus: PermaFocus.engagement,
      title: 'Strength Check',
      prompt: 'What personal strength did you use successfully today? Reflect on how it made you feel.',
      icon: Icons.psychology_outlined,
    ),
    PermaPrompt(
      focus: PermaFocus.engagement,
      title: 'Find Flow',
      prompt: 'Name one activity that makes you completely lose track of time. Plan 15 minutes to do it.',
      icon: Icons.stream_outlined,
    ),

    // R - Relationships (Connection, Kindness)
    PermaPrompt(
      focus: PermaFocus.relationships,
      title: 'Act of Kindness',
      prompt: 'Who can you send a short, encouraging message to today? Go make someone\'s day.',
      icon: Icons.send_time_extension_outlined,
    ),
    PermaPrompt(
      focus: PermaFocus.relationships,
      title: 'Connection',
      prompt: 'Think of a loved one. Journal one thing you deeply appreciate about them.',
      icon: Icons.people_outline,
    ),

    // M - Meaning (Purpose, Altruism)
    PermaPrompt(
      focus: PermaFocus.meaning,
      title: 'Purpose',
      prompt: 'What is one small step you can take today that aligns with your core values?',
      icon: Icons.lightbulb_outline,
    ),

    // A - Accomplishment (Achievement, Mastery)
    PermaPrompt(
      focus: PermaFocus.accomplishment,
      title: 'Micro-Victory',
      prompt: 'What small task did you complete today? Acknowledge that victory in your journal.',
      icon: Icons.check_circle_outline,
    ),
  ];

  // Method to get a prompt (can be made daily-specific later)
  static PermaPrompt getRandomPrompt() {
    final random = Random();
    return allPrompts[random.nextInt(allPrompts.length)];
  }
}