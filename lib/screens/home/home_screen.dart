// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'notebooks_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '/services/quote_service.dart';
import '/models/activity_model.dart';
import '/services/journal_service.dart';
import '/models/journal_model.dart';
import '/models/wellness_tasks_data.dart'; // Fallback tasks
import 'journal_entry_screen.dart';
import '../sessions/breathing_session.dart';
import '../sessions/yoga_selection.dart';
import '../sessions/meditation_selection.dart';
import '../journal/journal_hub_screen.dart'; // <--- CRITICAL IMPORT

class MoodItem {
  final String emoji;
  final String label;
  final Color color;
  MoodItem(this.emoji, this.label, this.color);
  static final List<MoodItem> allMoods = [
    MoodItem('😀', 'Fantastic', Colors.green),
    MoodItem('😌', 'Calm', Colors.lightGreen),
    MoodItem('😔', 'Sad', Colors.orange),
    MoodItem('😭', 'Anxious', Colors.red),
    MoodItem('😡', 'Angry', Colors.purple),
  ];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // --- WIDGET OPTIONS ---
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),
    const JournalHubScreen(),
    const DashboardScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen())),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2.0,
        child: const Icon(Icons.hub_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: theme.cardColor,
        elevation: 10.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(icon: Icons.home, index: 0, label: 'Home'),
              _buildNavItem(
                  icon: Icons.book_outlined, index: 1, label: 'Journal'),
              const SizedBox(width: 40),
              _buildNavItem(
                  icon: Icons.analytics_outlined, index: 2, label: 'Resources'),
              _buildNavItem(
                  icon: Icons.person_outline, index: 3, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required int index, required String label}) {
    return IconButton(
      icon: Icon(icon,
          color: _selectedIndex == index
              ? Theme.of(context).primaryColor
              : Colors.grey[600]),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Future<Quote>? _dailyQuoteFuture;
  bool _isLoadingQuote = true;
  MoodItem? _selectedMood;
  final List<Activity> _dailyActivities = Activity.defaultActivities;
  final JournalService _journalService = JournalService();

  List<String> _aiTasks = [];
  bool _isLoadingTasks = true;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
    _checkTodayMood();
    _fetchDailyTasks();
  }

  void _fetchQuote() {
    setState(() {
      _isLoadingQuote = true;
      _dailyQuoteFuture = QuoteService().fetchDailyQuote();
      _dailyQuoteFuture!.whenComplete(() {
        if (mounted) setState(() => _isLoadingQuote = false);
      });
    });
  }

  // AI Task Fetching logic
  Future<void> _fetchDailyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('daily_tasks_date');
    final savedTasks = prefs.getStringList('daily_tasks_list');

    if (savedDate == today && savedTasks != null && savedTasks.isNotEmpty) {
      if (mounted) {
        setState(() {
          _aiTasks = savedTasks;
          _isLoadingTasks = false;
        });
      }
      return;
    }

    try {
      const apiKey = ""; // Optional: Add API Key here if you want real AI

      if (apiKey.isEmpty) { throw Exception("No API Key"); }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final prompt = "Generate 3 simple wellness tasks (under 6 words). Format: Task 1|Task 2|Task 3";
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        final rawText = response.text!.trim();
        final tasks = rawText.split('|').map((e) => e.trim()).toList();

        await prefs.setString('daily_tasks_date', today);
        await prefs.setStringList('daily_tasks_list', tasks.sublist(0, 3));

        if (mounted) {
          setState(() {
            _aiTasks = tasks.sublist(0, 3);
            _isLoadingTasks = false;
          });
        }
        return;
      }
    } catch (e) {
      // Fallback
    }

    // Fallback to local random tasks
    final randomTasks = WellnessTasksData.getRandomTasks(count: 3);
    await prefs.setString('daily_tasks_date', today);
    await prefs.setStringList('daily_tasks_list', randomTasks);

    if (mounted) {
      setState(() {
        _aiTasks = randomTasks;
        _isLoadingTasks = false;
      });
    }
  }

  void _checkTodayMood() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final todayString = DateTime.now().toIso8601String().substring(0, 10);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('mood_logs')
          .where('userId', isEqualTo: user.uid)
          .where('dateLogged', isEqualTo: todayString).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final emoji = data['moodEmoji'];
        final moodItem = MoodItem.allMoods.firstWhere((m) => m.emoji == emoji, orElse: () => MoodItem(emoji, 'Mood', Colors.grey));
        if (mounted) setState(() { _selectedMood = moodItem; });
      }
    } catch (e) { print("Error checking mood: $e"); }
  }

  Future<void> _saveMoodToFirebase(MoodItem mood, String? note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final moodLogRef = FirebaseFirestore.instance.collection('mood_logs');
    final todayString = DateTime.now().toIso8601String().substring(0, 10);
    try {
      final querySnapshot = await moodLogRef.where('userId', isEqualTo: user.uid).where('dateLogged', isEqualTo: todayString).limit(1).get();
      final moodData = {'userId': user.uid, 'moodEmoji': mood.emoji, 'moodLabel': mood.label, 'note': note ?? '', 'timestamp': FieldValue.serverTimestamp(), 'dateLogged': todayString,};
      if (querySnapshot.docs.isNotEmpty) { await querySnapshot.docs.first.reference.update(moodData); } else { await moodLogRef.add(moodData); }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mood "${mood.label}" logged!')));
    } catch (e) { print("Firebase Mood Log Error: $e"); }
  }

  void _showMoodNoteDialog(MoodItem mood) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [Text(mood.emoji, style: const TextStyle(fontSize: 24)), const SizedBox(width: 8), Text('Feeling ${mood.label}?')]),
        content: TextField(controller: noteController, maxLength: 120, maxLines: 3, decoration: const InputDecoration(hintText: 'Why do you feel this way?', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () { setState(() => _selectedMood = mood); _saveMoodToFirebase(mood, null); Navigator.pop(context); }, child: const Text('Skip Note')),
          ElevatedButton(onPressed: () { setState(() => _selectedMood = mood); _saveMoodToFirebase(mood, noteController.text.trim()); Navigator.pop(context); }, child: const Text('Save Log')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Friend';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('YouMii Ai', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
              IconButton(icon: Icon(Icons.history_outlined, color: theme.iconTheme.color), onPressed: () {}),
            ]),
            const SizedBox(height: 30),
            Text('Welcome, $displayName', style: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            FutureBuilder<Quote>(
                future: _dailyQuoteFuture,
                builder: (context, quoteSnapshot) {
                  if (quoteSnapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: LinearProgressIndicator()));
                  final dailyQuote = quoteSnapshot.data ?? Quote(text: "Loading...", author: "");
                  return _DailyQuoteCard(quote: dailyQuote);
                }),
            const SizedBox(height: 20),
            _MoodLogCard(selectedMood: _selectedMood, onMoodSelected: (mood) => _showMoodNoteDialog(mood), onReset: () { setState(() { _selectedMood = null; }); }),
            const SizedBox(height: 40),
            Padding(padding: const EdgeInsets.only(left: 4.0, bottom: 12.0), child: Text('Activities', style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold))),
            _DailyProgressStrip(activities: _dailyActivities),
            const SizedBox(height: 40),
            Padding(padding: const EdgeInsets.only(left: 4.0, bottom: 12.0), child: Text('Daily Plan', style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold))),
            _DailyTasksCard(tasks: _aiTasks, isLoading: _isLoadingTasks),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS ---
class _DailyQuoteCard extends StatelessWidget {
  final Quote quote;
  const _DailyQuoteCard({required this.quote});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.format_quote_outlined, color: theme.primaryColor, size: 20), const SizedBox(width: 8), Text('Quote of the Day', style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[400]))]),
            const SizedBox(height: 12),
            Text('"${quote.text}"', style: theme.textTheme.titleMedium!.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerRight, child: Text('- ${quote.author}', style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey[500]))),
          ],
        ),
      ),
    );
  }
}

class _MoodLogCard extends StatelessWidget {
  final MoodItem? selectedMood;
  final Function(MoodItem) onMoodSelected;
  final VoidCallback onReset;
  const _MoodLogCard({required this.selectedMood, required this.onMoodSelected, required this.onReset});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (selectedMood != null) {
      return Card(
        elevation: 2.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), color: const Color(0xFFD3D3FF),
        child: InkWell(
          onTap: onReset, borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: selectedMood!.color, width: 2)), child: Text(selectedMood!.emoji, style: const TextStyle(fontSize: 32))),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Mood Logged', style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey[700])), Text(selectedMood!.label, style: theme.textTheme.titleLarge!.copyWith(color: Colors.black87, fontWeight: FontWeight.bold))])),
                Icon(Icons.edit, color: theme.primaryColor, size: 22),
              ],
            ),
          ),
        ),
      );
    }
    return Card(
      elevation: 4.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How do you feel today?', style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: MoodItem.allMoods.map((mood) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0), child: InkWell(onTap: () => onMoodSelected(mood), borderRadius: BorderRadius.circular(30), child: Container(padding: const EdgeInsets.symmetric(vertical: 4.0), alignment: Alignment.center, child: Text(mood.emoji, style: const TextStyle(fontSize: 32))))))).toList()),
          ],
        ),
      ),
    );
  }
}

class _DailyProgressStrip extends StatelessWidget {
  final List<Activity> activities;
  const _DailyProgressStrip({required this.activities});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Padding(
            padding: EdgeInsets.only(right: index == activities.length - 1 ? 0 : 16.0),
            child: InkWell(
              onTap: () {
                Widget? sessionScreen;
                if (activity.title == 'Yoga') sessionScreen = const YogaSelection();
                else if (activity.title == 'Breathing') sessionScreen = BreathingSession(activity: activity);
                else if (activity.title == 'Meditation') sessionScreen = const MeditationSelectionScreen();

                if (sessionScreen != null) { Navigator.push(context, MaterialPageRoute(builder: (context) => sessionScreen!)); }
                else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${activity.title} session is coming soon!'))); }
              },
              child: Container(
                width: 100, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(15)),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Icon(activity.icon, size: 32, color: activity.color), Text(activity.title, style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center), Text('${activity.totalTimeMinutes} min', style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey[500]))]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DailyTasksCard extends StatelessWidget {
  final List<String> tasks;
  final bool isLoading;
  const _DailyTasksCard({required this.tasks, required this.isLoading});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return Card(
      elevation: 2.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: tasks.map((task) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [Icon(Icons.check_circle_outline, color: theme.primaryColor), const SizedBox(width: 12), Expanded(child: Text(task, style: theme.textTheme.bodyLarge))]))).toList()),
      ),
    );
  }
}