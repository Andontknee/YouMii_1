// lib/screens/sessions/yoga_selection.dart

import 'package:flutter/material.dart';
import '../../models/yoga_model.dart';
import 'yoga_session.dart';

class YogaSelection extends StatelessWidget {
  const YogaSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // FIX: Access the list of poses directly
    final poses = YogaPose.allPoses;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Select a Pose'), // Updated Title
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
        titleTextStyle: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: poses.length,
        itemBuilder: (context, index) {
          final pose = poses[index]; // Get the individual pose

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16.0),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black12, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pose.title,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Show duration in minutes
                  Text(
                    'Duration: ${pose.durationSeconds ~/ 60} minutes',
                    style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pose.description,
                    style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black54),
                    maxLines: 2, // Limit text so the card isn't huge
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // FIX: Pass the single pose to the session screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => YogaSession(pose: pose)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Start'),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}