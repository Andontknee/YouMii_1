// lib/models/yoga_model.dart

import 'package:flutter/material.dart';
import 'activity_model.dart'; // We need the base Activity model

// A single step within a yoga pose/exercise
class YogaStep {
  final String instruction;
  final int durationSeconds;

  YogaStep({required this.instruction, required this.durationSeconds});
}

// A full yoga pose with multiple steps
class YogaPose {
  final String title;
  final String permaConnection;
  final String whyItHelps;
  final List<YogaStep> steps;

  YogaPose({
    required this.title,
    required this.permaConnection,
    required this.whyItHelps,
    required this.steps,
  });
}

// A complete yoga session, which is a collection of poses
class YogaSessionData {
  final String title;
  final String description;
  final int totalMinutes;
  final List<YogaPose> poses;

  YogaSessionData({
    required this.title,
    required this.description,
    required this.totalMinutes,
    required this.poses,
  });

  // --- THIS IS WHERE WE STORE ALL OUR YOGA SESSIONS ---
  static List<YogaSessionData> get allSessions => [
    // Session 1: Calming Beginner Flow
    YogaSessionData(
      title: 'Calming Beginner Flow',
      description: 'A gentle 5-minute session to release tension and calm the nervous system.',
      totalMinutes: 5,
      poses: [
        // Pose 1
        YogaPose(
          title: "Child's Pose (Balasana)",
          permaConnection: 'Positive Emotions, Engagement',
          whyItHelps: 'Gently stretches the back and hips, calming the brain and encouraging a sense of security.',
          steps: [
            YogaStep(instruction: 'Kneel on your mat with knees wide. Fold forward, resting your torso between your thighs.', durationSeconds: 15),
            YogaStep(instruction: 'Rest your forehead on the floor. Bring your arms alongside your body, palms up.', durationSeconds: 10),
            YogaStep(instruction: 'Hold for 1 minute. Focus on sending your breath into your back.', durationSeconds: 60),
          ],
        ),
        // Pose 2
        YogaPose(
          title: 'Cat-Cow Stretch (Marjaryasana-Bitilasana)',
          permaConnection: 'Engagement, Accomplishment',
          whyItHelps: 'A moving meditation that calms the mind and releases tension in the spine and neck.',
          steps: [
            YogaStep(instruction: 'Start on your hands and knees in a tabletop position.', durationSeconds: 10),
            YogaStep(instruction: 'Inhale: Drop your belly, lift your chest and tailbone (Cow Pose).', durationSeconds: 5),
            YogaStep(instruction: 'Exhale: Round your spine, tuck your tailbone (Cat Pose).', durationSeconds: 5),
            YogaStep(instruction: 'Flow between Cat and Cow for 5 rounds, syncing with your breath.', durationSeconds: 50),
          ],
        ),
        // Pose 3
        YogaPose(
          title: 'Legs-Up-The-Wall Pose (Viparita Karani)',
          permaConnection: 'Positive Emotions, Meaning',
          whyItHelps: 'A gentle inversion that calms the nervous system and soothes headaches.',
          steps: [
            YogaStep(instruction: 'Sit with one hip against a wall. Lie back and swing your legs up the wall.', durationSeconds: 15),
            YogaStep(instruction: 'Rest your arms out to the sides, palms up. Close your eyes and surrender.', durationSeconds: 10),
            YogaStep(instruction: 'Hold this deeply restorative pose for 2 minutes.', durationSeconds: 120),
          ],
        ),
      ],
    ),
    // Add more YogaSessionData objects here for "Yoga Exercise 2", "Yoga for Energy", etc.
  ];
}