// lib/screens/journal/journal_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../home/notebooks_screen.dart'; // Reuse your existing notebook screen
import '../home/dashboard_screen.dart'; // Placeholder if you still have it
import '../home/profile_screen.dart';   // Placeholder

class JournalHubScreen extends StatelessWidget {
  const JournalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Journal & Moods'),
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Mood Calendar', icon: Icon(Icons.calendar_month_outlined)),
              Tab(text: 'Notebooks', icon: Icon(Icons.book_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MoodCalendarTab(), // We define this below
            NotebooksScreen(), // We reuse your existing screen
          ],
        ),
      ),
    );
  }
}

class MoodCalendarTab extends StatefulWidget {
  const MoodCalendarTab({super.key});

  @override
  State<MoodCalendarTab> createState() => _MoodCalendarTabState();
}

class _MoodCalendarTabState extends State<MoodCalendarTab> {
  DateTime _focusedDay = DateTime.now();
  Map<String, Map<String, dynamic>> _moodData = {}; // {DateString: {emoji: "X", note: "Y"}}
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoodsForMonth(_focusedDay);
  }

  Future<void> _fetchMoodsForMonth(DateTime date) async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Calculate start/end of month
    final start = DateTime(date.year, date.month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(date.year, date.month + 1, 0).toIso8601String().substring(0, 10);

    final snapshot = await FirebaseFirestore.instance
        .collection('mood_logs')
        .where('userId', isEqualTo: user.uid)
        .where('dateLogged', isGreaterThanOrEqualTo: start)
        .where('dateLogged', isLessThanOrEqualTo: end)
        .get();

    final Map<String, Map<String, dynamic>> newData = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['dateLogged'] != null) {
        newData[data['dateLogged']] = {
          'emoji': data['moodEmoji'],
          'note': data['note'] ?? '',
        };
      }
    }

    if (mounted) {
      setState(() {
        _moodData = newData;
        _isLoading = false;
      });
    }
  }

  void _showMoodDetails(String dateKey, String emoji, String note) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood for $dateKey', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Center(child: Text(emoji, style: const TextStyle(fontSize: 60))),
            const SizedBox(height: 24),
            const Text('Your Note:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  note.isEmpty ? "No note added for this day." : note,
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalDays = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstWeekday = DateTime(_focusedDay.year, _focusedDay.month, 1).weekday;

    return Column(
      children: [
        // --- Header with Month Navigation ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                    _fetchMoodsForMonth(_focusedDay);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedDay),
                style: theme.textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                    _fetchMoodsForMonth(_focusedDay);
                  });
                },
              ),
            ],
          ),
        ),

        // --- Calendar Grid ---
        _isLoading
            ? const Expanded(child: Center(child: CircularProgressIndicator()))
            : Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: totalDays + firstWeekday - 1,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) return const SizedBox.shrink();

              final day = index - (firstWeekday - 2);
              final dateKey = DateTime(_focusedDay.year, _focusedDay.month, day)
                  .toIso8601String()
                  .substring(0, 10);

              final hasMood = _moodData.containsKey(dateKey);
              final moodInfo = _moodData[dateKey];

              return InkWell(
                onTap: hasMood
                    ? () => _showMoodDetails(dateKey, moodInfo!['emoji'], moodInfo['note'])
                    : null,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: hasMood ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: hasMood ? Border.all(color: theme.primaryColor) : null,
                  ),
                  child: Center(
                    child: hasMood
                        ? Text(moodInfo!['emoji'], style: const TextStyle(fontSize: 20))
                        : Text(day.toString(), style: TextStyle(color: Colors.grey[600])),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}