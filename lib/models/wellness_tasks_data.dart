// lib/models/wellness_tasks_data.dart

import 'dart:math';

class WellnessTasksData {
  // A large pool of fallback tasks
  static final List<String> _allTasks = [
    "Drink a full glass of water right now",
    "Take 5 deep, slow breaths",
    "Step outside for fresh air",
    "Stretch your neck and shoulders",
    "Write down one thing you're grateful for",
    "Put your phone away for 15 minutes",
    "Listen to your favorite song",
    "Tidy up one small area of your room",
    "Send a kind text to a friend",
    "Do a 1-minute plank",
    "Read 5 pages of a book",
    "Close your eyes and rest for 2 minutes",
    "Eat a piece of fruit",
    "Compliment yourself in the mirror",
    "Walk 500 steps",
    "Avoid sugary drinks for the rest of the day",
    "Write down one goal for tomorrow",
    "Do 10 jumping jacks",
    "Watch a funny video to laugh",
    "Practice good posture for the next hour",
  ];

  // Function to get 3 random tasks
  static List<String> getRandomTasks({int count = 3}) {
    final random = Random();
    // Create a copy of the list to shuffle
    final List<String> shuffledTasks = List.from(_allTasks)..shuffle(random);
    // Return the first 'count' items (e.g., 3)
    return shuffledTasks.take(count).toList();
  }
}