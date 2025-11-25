// lib/models/activity_model.dart

import 'package:flutter/material.dart';

class Activity {
  final String title;
  final IconData icon;
  final Color color;
  final int totalTimeMinutes;
  bool isCompleted;

  Activity({
    required this.title,
    required this.icon,
    required this.color,
    required this.totalTimeMinutes,
    this.isCompleted = false,
  });

  // "Light Walk" has been removed.
  static List<Activity> get defaultActivities => [
    Activity(title: 'Meditation', icon: Icons.self_improvement_outlined, color: Colors.blueGrey, totalTimeMinutes: 10),
    Activity(title: 'Breathing', icon: Icons.bubble_chart_outlined, color: Colors.indigo, totalTimeMinutes: 5),
    Activity(title: 'Yoga', icon: Icons.sports_gymnastics_outlined, color: Colors.purple, totalTimeMinutes: 15),
  ];
}