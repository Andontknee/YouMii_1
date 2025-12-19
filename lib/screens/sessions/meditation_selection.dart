// lib/screens/sessions/meditation_selection.dart

import 'package:flutter/material.dart';
import '../../models/meditation_model.dart';
import 'meditation_session.dart';

class MeditationSelectionScreen extends StatelessWidget {
  const MeditationSelectionScreen({super.key});

  void _showDurationDialog(BuildContext context, MeditationType type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set Duration for ${type.title}',
                style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // The fixed timers you requested: 3, 5, 10
              _DurationOption(context, type, 3, "3 Minutes (Quick Reset)"),
              _DurationOption(context, type, 5, "5 Minutes (Standard)"),
              _DurationOption(context, type, 10, "10 Minutes (Deep Dive)"),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = MeditationType.allTypes;

    return Scaffold(
      backgroundColor: const Color(0xFFEBF4FA), // Pale Blue Background
      appBar: AppBar(
        title: const Text('Meditation Space'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return Card(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              onTap: () => _showDurationDialog(context, session),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: session.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(session.icon, color: session.color, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.title,
                            style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.subtitle,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.play_circle_outline, color: Colors.grey, size: 28),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  final BuildContext context;
  final MeditationType type;
  final int minutes;
  final String label;

  const _DurationOption(this.context, this.type, this.minutes, this.label);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.timer, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeditationSessionScreen(type: type, minutes: minutes),
          ),
        );
      },
    );
  }
}