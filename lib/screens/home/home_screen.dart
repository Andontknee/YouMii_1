// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
// Note: We are importing individual classes from dashboard_screen if they are in the same file
import 'dashboard_screen.dart';
import 'notebooks_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/quote_service.dart';
import '/models/activity_model.dart';
import '/services/journal_service.dart';
import '/models/journal_model.dart';
import '/models/wellness_tasks_data.dart';
import 'journal_entry_screen.dart';
import '../sessions/breathing_session.dart';
import '../sessions/yoga_selection.dart';
import '../sessions/meditation_selection.dart';
import '../journal/journal_hub_screen.dart';

// --- MOOD LOG DATA STRUCTURE ---
class MoodItem {
  final String emoji;
  final String label;
  final Color color;
  MoodItem(this.emoji, this.label, this.color);
  static final List<MoodItem> allMoods = [
    MoodItem('😀', 'Fantastic', Colors.green),
    MoodItem('😌', 'Calm', Colors.teal),
    MoodItem('😔', 'Sad', Colors.orange),
    MoodItem('😭', 'Anxious', Colors.redAccent),
    MoodItem('😡', 'Angry', Colors.deepPurple),
  ];
}
// ---------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // --- THE 5 MAIN TABS ---
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),        // 0: Home
    const JournalHubScreen(),   // 1: Journal & Calendar
    const SupportScreen(),      // 2: Support (Emergency/Events/Contacts) - From dashboard_screen.dart
    const ReadingScreen(),      // 3: Articles - From dashboard_screen.dart
    const ProfileScreen(),      // 4: Profile
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

      // Dynamic Body
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),

      // Chatbot Button (Bottom Right)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen())),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: const CircleBorder(),
        // CHANGE IS HERE: Use Image.asset instead of Icon
        child: Padding(
          padding: const EdgeInsets.all(1.0), // Adds padding so the image isn't too close to the edge
          child: Image.asset(
            'assets/mascot.png', // Make sure this path matches your mascot file
            fit: BoxFit.contain,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // --- NAVIGATION BAR ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0, // Reduced slightly
        color: Colors.white, // FIX: Force White Background
        surfaceTintColor: Colors.white, // FIX: Remove Material 3 purple tint
        elevation: 10.0,
        height: 70, // Height for 5 icons
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Use SpaceEvenly for 5 items
          children: <Widget>[
            _buildNavItem(icon: Icons.home_rounded, index: 0, label: 'Home'),
            _buildNavItem(icon: Icons.book_rounded, index: 1, label: 'Journal'),
            // Separate Tabs
            _buildNavItem(icon: Icons.people_alt_rounded, index: 2, label: 'Support'),
            _buildNavItem(icon: Icons.menu_book_rounded, index: 3, label: 'Read'),

            _buildNavItem(icon: Icons.person_rounded, index: 4, label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index, required String label}) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(icon,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400],
          size: 26),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

// --- HOME CONTENT TAB ---
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

  Future<void> _fetchDailyTasks() async {
    final randomTasks = WellnessTasksData.getRandomTasks(count: 3);
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

  // DIALOG FOR MOOD NOTES
  void _showMoodNoteDialog(MoodItem mood) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Row(children: [Text(mood.emoji, style: const TextStyle(fontSize: 24)), const SizedBox(width: 8), Text('Feeling ${mood.label}?')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add a short note about your day (optional):'),
            const SizedBox(height: 16),
            TextField(controller: noteController, maxLength: 120, maxLines: 3, decoration: const InputDecoration(hintText: 'Why do you feel this way?', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
          ],
        ),
        actions: [
          TextButton(onPressed: () { setState(() => _selectedMood = mood); _saveMoodToFirebase(mood, null); Navigator.pop(context); }, child: const Text('Skip Note')),
          ElevatedButton(onPressed: () { setState(() => _selectedMood = mood); _saveMoodToFirebase(mood, noteController.text.trim()); Navigator.pop(context); }, child: const Text('Save Log')),
        ],
      ),
    );
  }

  // NOTE: Daily Quote doesn't open a journal dialog anymore (requested removal)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Friend';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('YouMii', style: theme.textTheme.headlineSmall!.copyWith(color: theme.primaryColor)),
              // Profile pic removed here
            ]),
            const SizedBox(height: 24),
            Text('Hello, $displayName', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 24),

            // --- 1. DAILY QUOTE ---
            FutureBuilder<Quote>(
                future: _dailyQuoteFuture,
                builder: (context, quoteSnapshot) {
                  if (quoteSnapshot.connectionState == ConnectionState.waiting) return const Center(child: LinearProgressIndicator());
                  final dailyQuote = quoteSnapshot.data ?? Quote(text: "Loading...", author: "");
                  return _DailyQuoteCard(quote: dailyQuote);
                }),

            const SizedBox(height: 20),

            // --- 2. MOOD LOG ---
            _MoodLogCard(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) => _showMoodNoteDialog(mood),
                onReset: () { setState(() { _selectedMood = null; }); }
            ),

            const SizedBox(height: 30),

            // --- 3. ACTIVITIES ---
            Padding(padding: const EdgeInsets.only(left: 4.0, bottom: 12.0), child: Text('Wellness Tools', style: theme.textTheme.titleLarge)),
            _DailyProgressStrip(activities: _dailyActivities, cardColor: const Color(0xFFE0F2F1)),

            const SizedBox(height: 20),

            // --- 4. DAILY PLAN (CHECKBOXES) ---
            _DailyTasksCard(tasks: _aiTasks, isLoading: _isLoadingTasks, cardColor: const Color(0xFFA4A5F5)),
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
    return Card(
      color: const Color(0xFF9EF0FF), // Cyan
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.format_quote_rounded, color: Colors.blueAccent, size: 24),
              SizedBox(width: 8),
              Text('Quote of the Day', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Text('"${quote.text}"', style: Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.5)),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: Text('- ${quote.author}', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black54))),
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
    const summaryCardColor = Color(0xFFCCCCFF);
    const inputCardColor = Color(0xFFFFF9E6); // Light Peach/Yellow

    // State 1: Summary (Already logged)
    if (selectedMood != null) {
      return Card(
        color: summaryCardColor,
        child: InkWell(
          onTap: onReset, borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: selectedMood!.color, width: 2)), child: Text(selectedMood!.emoji, style: const TextStyle(fontSize: 32))),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Mood Logged', style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey[700])), Text(selectedMood!.label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])),
                Icon(Icons.edit, color: theme.primaryColor),
              ],
            ),
          ),
        ),
      );
    }

    // State 2: Input (Select Emoji)
    return Card(
      color: inputCardColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How do you feel today?', style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.brown.shade700)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: MoodItem.allMoods.map((mood) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: InkWell(onTap: () => onMoodSelected(mood), borderRadius: BorderRadius.circular(30), child: Container(padding: const EdgeInsets.symmetric(vertical: 8.0), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.orange.withOpacity(0.1), width: 1)), child: Text(mood.emoji, style: const TextStyle(fontSize: 28), textAlign: TextAlign.center)))))).toList()),
          ],
        ),
      ),
    );
  }
}

class _DailyProgressStrip extends StatelessWidget {
  final List<Activity> activities;
  final Color cardColor;
  const _DailyProgressStrip({required this.activities, required this.cardColor});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
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
                width: 110,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cardColor.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: cardColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(activity.icon, size: 24, color: Colors.teal),
                    ),
                    Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                    Text('${activity.totalTimeMinutes}m', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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

class _DailyTasksCard extends StatefulWidget {
  final List<String> tasks;
  final bool isLoading;
  final Color cardColor;
  const _DailyTasksCard({required this.tasks, required this.isLoading, required this.cardColor});
  @override
  State<_DailyTasksCard> createState() => _DailyTasksCardState();
}

class _DailyTasksCardState extends State<_DailyTasksCard> {
  late List<bool> _taskStatus;

  @override
  void initState() {
    super.initState();
    _taskStatus = List.generate(widget.tasks.length, (index) => false);
  }

  @override
  void didUpdateWidget(_DailyTasksCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tasks.length != oldWidget.tasks.length) {
      _taskStatus = List.generate(widget.tasks.length, (index) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));

    return Card(
      color: widget.cardColor.withOpacity(0.25),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.eco, color: widget.cardColor),
              const SizedBox(width: 8),
              const Text("Daily Plan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 12),

            // Checkboxes logic
            ...List.generate(widget.tasks.length, (index) {
              final task = widget.tasks[index];
              final isChecked = _taskStatus.length > index ? _taskStatus[index] : false;
              return InkWell(
                onTap: () { setState(() { _taskStatus[index] = !isChecked; }); },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(task, style: TextStyle(fontSize: 15, color: isChecked ? Colors.grey : Colors.black87, decoration: isChecked ? TextDecoration.lineThrough : null))),
                      const SizedBox(width: 12),
                      Icon(isChecked ? Icons.check_circle : Icons.circle_outlined, size: 24, color: isChecked ? widget.cardColor : Colors.grey),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}