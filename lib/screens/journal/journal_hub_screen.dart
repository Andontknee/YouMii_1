// lib/screens/journal/journal_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../home/notebooks_screen.dart';
import '../home/home_screen.dart'; // To access MoodItem class
// --- IMPORT THE NEW CARD HERE ---
import 'mood_insight_card.dart';

// --- MOOD SERVICE ---
class MoodService {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference _moodCollection =
  FirebaseFirestore.instance.collection('mood_logs');

  Future<Map<String, Map<String, dynamic>>> fetchMonthlyMoods(DateTime month) async {
    if (user == null) return {};

    final start = DateTime(month.year, month.month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(month.year, month.month + 1, 0).toIso8601String().substring(0, 10);

    final snapshot = await _moodCollection
        .where('userId', isEqualTo: user!.uid)
        .where('dateLogged', isGreaterThanOrEqualTo: start)
        .where('dateLogged', isLessThanOrEqualTo: end)
        .get();

    final Map<String, Map<String, dynamic>> moodMap = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['dateLogged'] != null) {
        moodMap[data['dateLogged']] = {
          'emoji': data['moodEmoji'],
          'note': data['note'] ?? '',
        };
      }
    }
    return moodMap;
  }
}

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
          title: const Text('My Journal'),
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
            MoodCalendarTab(),
            NotebooksScreen(),
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
  Map<String, Map<String, dynamic>> _moodData = {};
  final MoodService _moodService = MoodService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoods();
  }

  void _fetchMoods() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _moodService.fetchMonthlyMoods(_focusedDay);
      if (mounted) {
        setState(() {
          _moodData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Calendar Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  MoodItem _getMoodDetails(String emoji) {
    try {
      return MoodItem.allMoods.firstWhere((item) => item.emoji == emoji);
    } catch (_) {
      return MoodItem('?', 'Unknown', Colors.grey);
    }
  }

  void _showMoodDetails(String dateKey, String emoji, String note) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Mood for $dateKey', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _getMoodDetails(emoji).color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text(_getMoodDetails(emoji).label, style: TextStyle(color: _getMoodDetails(emoji).color, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 24),
            Center(child: Text(emoji, style: const TextStyle(fontSize: 80))),
            const SizedBox(height: 24),
            const Text('Your Note:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    note.isEmpty ? "No note added for this day." : note,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
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
        // 1. Navigation
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
                    _fetchMoods();
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedDay),
                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                    _fetchMoods();
                  });
                },
              ),
            ],
          ),
        ),

        // 2. Weekday Labels
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Mon', style: TextStyle(color: Colors.grey)), Text('Tue', style: TextStyle(color: Colors.grey)),
              Text('Wed', style: TextStyle(color: Colors.grey)), Text('Thu', style: TextStyle(color: Colors.grey)),
              Text('Fri', style: TextStyle(color: Colors.grey)), Text('Sat', style: TextStyle(color: Colors.grey)),
              Text('Sun', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),

        // 3. The Grid View (Fills available space)
        _isLoading
            ? const Expanded(child: Center(child: CircularProgressIndicator()))
            : Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: totalDays + firstWeekday - 1,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) return const SizedBox.shrink();
              final day = index - (firstWeekday - 2);
              final dateKey = DateTime(_focusedDay.year, _focusedDay.month, day).toIso8601String().substring(0, 10);
              final hasMood = _moodData.containsKey(dateKey);
              final moodInfo = _moodData[dateKey];
              final moodColor = hasMood ? _getMoodDetails(moodInfo!['emoji']).color : Colors.transparent;

              return InkWell(
                onTap: hasMood ? () => _showMoodDetails(dateKey, moodInfo!['emoji'], moodInfo['note']) : null,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: hasMood ? moodColor.withOpacity(0.2) : Colors.transparent,
                    border: !hasMood ? Border.all(color: Colors.grey[200]!, width: 1) : Border.all(color: moodColor, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(day.toString(), style: TextStyle(color: hasMood ? Colors.black87 : Colors.grey[600], fontWeight: hasMood ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                      if (hasMood) ...[const SizedBox(height: 4), Text(moodInfo!['emoji'], style: const TextStyle(fontSize: 24))]
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 4. --- ADDED: The AI Insight Card at the bottom ---
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: MoodInsightCard(),
        ),
      ],
    );
  }
}