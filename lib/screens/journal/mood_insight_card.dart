
// lib/screens/journal/mood_insight_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/chat_service.dart';

class MoodInsightCard extends StatefulWidget {
  const MoodInsightCard({super.key});

  @override
  State<MoodInsightCard> createState() => _MoodInsightCardState();
}

class _MoodInsightCardState extends State<MoodInsightCard> {
  final ChatService _chatService = ChatService(); // Reuses your existing chat service
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _analysis;
  bool _isLoading = false;

  Future<void> _generateInsight() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Calculate Date String for 7 days ago (format YYYY-MM-DD)
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final startString = sevenDaysAgo.toIso8601String().substring(0, 10);

      // 2. Fetch from your SPECIFIC 'mood_logs' collection structure
      final snapshot = await _firestore
          .collection('mood_logs')
          .where('userId', isEqualTo: user.uid)
          .where('dateLogged', isGreaterThanOrEqualTo: startString)
          .orderBy('dateLogged')
          .get();

      if (snapshot.docs.isEmpty) {
        if (mounted) setState(() => _analysis = "No mood logs found for the last 7 days.");
        return;
      }

      // 3. Extract Emojis and Notes to send to AI
      // formatting like: "2024-01-01: 🙂 (Note: Tired)"
      List<String> logs = snapshot.docs.map((doc) {
        final data = doc.data();
        final emoji = data['moodEmoji'] ?? '';
        final note = data['note'] ?? '';
        return "$emoji ${note.isNotEmpty ? '($note)' : ''}";
      }).toList();

      // 4. Send to Gemini
      final result = await _chatService.analyzeMoodTrend(logs);

      if (mounted) {
        setState(() {
          _analysis = result;
        });
      }
    } catch (e) {
      if (mounted) {
        // print(e); // Debug if needed
        setState(() => _analysis = "Couldn't connect to AI right now.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine current theme colors or defaults
    final theme = Theme.of(context);
    final kAccentColor = theme.primaryColor;

    return Container(
      width: double.infinity,
      // Minimal styling to blend with your Journal Hub
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // shrink to fit
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_alt, color: kAccentColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "AI Mood Insight",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (_analysis != null && !_isLoading)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                  onPressed: _generateInsight,
                  tooltip: "Refresh Analysis",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // --- CONTENT STATE ---
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: kAccentColor)
                ),
              ),
            )
          else if (_analysis == null)
            Center(
              child: TextButton.icon(
                onPressed: _generateInsight,
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text("Tap to analyze recent moods"),
                style: TextButton.styleFrom(foregroundColor: kAccentColor),
              ),
            )
          else
            Text(
              _analysis!,
              style: const TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 14,
                  height: 1.4,
                  fontStyle: FontStyle.italic
              ),
            ),
        ],
      ),
    );
  }
}