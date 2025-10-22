import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Wellness Journey',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.mood, color: Colors.green),
                title: const Text('Mood Tracking'),
                subtitle: const Text('Coming Soon'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.track_changes, color: Colors.blue),
                title: const Text('Habit Tracker'),
                subtitle: const Text('Coming Soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}