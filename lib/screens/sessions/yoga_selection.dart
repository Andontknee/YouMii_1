// lib/screens/sessions/yoga_selection.dart

import 'package:flutter/material.dart';
// --- CORRECTED IMPORT PATHS ---
import '/models/yoga_model.dart';
import 'yoga_session.dart';
// --- END OF CORRECTION ---

class YogaSelection extends StatelessWidget {
  const YogaSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // This uses the static list from our model file.
    final sessions = YogaSessionData.allSessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Yoga Session'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${session.poses.length} Poses • Approx. ${session.totalMinutes} minutes',
                    style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => YogaSession(sessionData: session)),
                        );
                      },
                      child: const Text('Get Started'),
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