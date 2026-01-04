// lib/models/yoga_model.dart

import 'package:flutter/material.dart';

class YogaPose {
  final String title;
  final String description;
  final String imageAsset;
  final int durationSeconds;

  YogaPose({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.durationSeconds,
  });

  // --- FLAT LIST OF INDIVIDUAL POSES ---
  static List<YogaPose> get allPoses => [
    YogaPose(
      title: "Child's Pose",
      description: "Kneel on your mat with knees wide. Fold forward, resting your forehead on the floor. Extend arms forward or keep them by your side. Breathe deeply into your back.",
      imageAsset: 'assets/yoga/child_pose.jpg',
      durationSeconds: 180, // 3 Minutes
    ),
    YogaPose(
      title: 'Cat-Cow Flow',
      description: "On hands and knees, inhale to drop your belly and lift your chest (Cow). Exhale to round your spine (Cat). Move slowly with your breath.",
      imageAsset: 'assets/yoga/cat_cow.webp',
      durationSeconds: 180, // 3 Minutes
    ),
    YogaPose(
      title: 'Legs-Up-The-Wall',
      description: "Sit sideways against a wall, then swing your legs up. Lie back and let your arms rest by your sides. Close your eyes and relax completely.",
      imageAsset: 'assets/yoga/legs_up.jpeg',
      durationSeconds: 180, // 3 Minutes
    ),
  ];
}