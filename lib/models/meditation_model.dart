// lib/models/meditation_model.dart

import 'package:flutter/material.dart';

class MeditationType {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> steps;
  final String imageAsset; // NEW FIELD

  MeditationType({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.steps,
    required this.imageAsset, // NEW REQUIRED
  });

  static List<MeditationType> get allTypes => [
    // 1. Mindfulness of Breath
    MeditationType(
      title: 'Mindfulness of Breath',
      subtitle: 'Anxiety & Focus',
      icon: Icons.air,
      color: Colors.lightBlueAccent,
      imageAsset: 'assets/meditation/breath.png', // Ensure this file exists!
      steps: [
        "Sit or lie down comfortably. Relax your shoulders.",
        "Close your eyes or soften your gaze.",
        "Bring your attention to your natural breathing. Do not try to control it.",
        "Notice the air entering your nose, and your chest rising.",
        "If thoughts appear, acknowledge them without judgment.",
        "Gently return your attention to your breath.",
        "Continue noticing the rhythm of your inhale and exhale.",
        "Stay with the breath.",
        "Slowly bring your awareness back to the room. Open your eyes.",
      ],
    ),
    // 2. Body Scan
    MeditationType(
      title: 'Body Scan',
      subtitle: 'Stress & Sleep',
      icon: Icons.accessibility_new,
      color: Colors.indigoAccent,
      imageAsset: 'assets/meditation/body_scan.png',
      steps: [
        "Lie down or sit comfortably. Take a few slow breaths.",
        "Bring your attention to your feet. Notice any warmth or tension.",
        "Slowly move your attention up to your calves and thighs.",
        "Notice your abdomen, chest, and shoulders. Let them relax.",
        "Move your attention down your arms to your hands.",
        "Bring focus to your neck, face, and head. Soften your jaw.",
        "Observe your whole body resting here.",
        "If your mind wanders, gently return to the current body area.",
        "Feel the weight of your body relaxing completely.",
        "When ready, gently wiggle your fingers and toes.",
      ],
    ),
    // 3. Loving-Kindness
    MeditationType(
      title: 'Loving-Kindness',
      subtitle: 'Self-Compassion & Healing',
      icon: Icons.volunteer_activism,
      color: Colors.pinkAccent,
      imageAsset: 'assets/meditation/love.png',
      steps: [
        "Sit comfortably and close your eyes.",
        "Bring your attention to your heart center.",
        "Silently repeat: 'May I be safe.'",
        "Repeat: 'May I be calm.'",
        "Repeat: 'May I be kind to myself.'",
        "Repeat: 'May I be at peace.'",
        "Let any feelings arise naturally. It is okay to feel neutral.",
        "Now, extend this wish to someone you care about.",
        "Extend this wish to someone neutral, or even difficult.",
        "Return the focus to yourself. 'May I be happy.'",
        "Take a deep breath and open your eyes.",
      ],
    ),
  ];
}