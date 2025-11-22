// lib/models/meditation_model.dart

import 'package:flutter/material.dart';

class MeditationType {
  final String title;
  final String subtitle; // The PERMA connection
  final IconData icon;
  final Color color;
  final List<String> guideScripts; // The text that will cycle on screen

  MeditationType({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.guideScripts,
  });

  // The 4 PERMA-based Meditation Types
  static List<MeditationType> get allTypes => [
    // 1. Engagement/Flow
    MeditationType(
      title: 'Deep Focus',
      subtitle: 'Engagement & Mindfulness',
      icon: Icons.center_focus_strong,
      color: Colors.teal,
      guideScripts: [
        "Find a comfortable seated position. Rest your hands on your knees.",
        "Close your eyes. Take a deep breath in... and let it go.",
        "Bring your full attention to the sensation of breathing.",
        "Notice the cool air entering your nose...",
        "And the warm air leaving your body.",
        "If your mind wanders, gently bring it back to the breath.",
        "You are exactly where you need to be.",
        "Focus...",
        "Stay with the breath.",
      ],
    ),
    // 2. Positive Emotion/Gratitude
    MeditationType(
      title: 'Gratitude',
      subtitle: 'Positive Emotion & Joy',
      icon: Icons.favorite,
      color: Colors.pinkAccent,
      guideScripts: [
        "Sit comfortably and relax your shoulders.",
        "Take a slow, deep breath. Smile gently.",
        "Bring to mind one thing you are grateful for today.",
        "It could be a person, a place, or a small comfort.",
        "Visualize this thing clearly in your mind.",
        "Notice how it makes you feel. Warm? Light? Happy?",
        "Let that feeling of gratitude expand in your chest.",
        "Silently say: 'Thank you.'",
      ],
    ),
    // 3. Relationships/Kindness
    MeditationType(
      title: 'Loving Kindness',
      subtitle: 'Relationships & Connection',
      icon: Icons.volunteer_activism,
      color: Colors.orange,
      guideScripts: [
        "Settle into stillness. Soften your face and jaw.",
        "Bring to mind someone you love deeply.",
        "Wish them well silently: 'May you be happy.'",
        "Now, think of yourself. You deserve kindness too.",
        "Say to yourself: 'May I be safe. May I be peaceful.'",
        "Think of an acquaintance or stranger.",
        "Send them a thought of goodwill.",
        "We are all connected. Breathe in that connection.",
      ],
    ),
    // 4. Meaning/Purpose
    MeditationType(
      title: 'Inner Purpose',
      subtitle: 'Meaning & Values',
      icon: Icons.lightbulb,
      color: Colors.indigo,
      guideScripts: [
        "Find your center. Breathe deeply into your belly.",
        "Ask yourself: What truly matters to me right now?",
        "Don't search for the answer. Just let it come.",
        "Visualize your best future self.",
        "What value are you bringing to the world?",
        "Feel the strength of your purpose grounding you.",
        "You are capable. You are driven.",
        "Carry this intention with you.",
      ],
    ),
  ];
}