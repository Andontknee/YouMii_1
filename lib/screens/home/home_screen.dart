// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
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

// --- MOOD LOG DATA ---
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
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

      // --- FIXED NAVIGATION BAR ---
      bottomNavigationBar: BottomAppBar(
        // Force White background
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 10.0,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(icon: Icons.home_rounded, index: 0, label: 'Home'),
            _buildNavItem(icon: Icons.book_rounded, index: 1, label: 'Journal'),

            // --- STATIC CENTER BUTTON ---
            // Fixed in place, but styled to look vibrant
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen())),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: theme.primaryColor, // Lavender
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: theme.primaryColor.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4)
                      )
                    ]
                ),
                child: const Icon(Icons.hub_outlined, color: Colors.white, size: 28),
              ),
            ),
            // -----------------------------

            _buildNavItem(icon: Icons.grid_view_rounded, index: 2, label: 'Resources'),
            _buildNavItem(icon: Icons.person_rounded, index: 3, label: 'Profile'),
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
          size: 28),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
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

  void _showJournalPromptDialog(Quote quote) {
    final titleController = TextEditingController(text: "Daily Inspiration");
    final contentController = TextEditingController(
        text: '"${quote.text}"\n- ${quote.author}\n\nMy reflection on this:\n');
    final newNotebookController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String? selectedNotebookId;
            bool isCreatingNewNotebook = false;

            void showCreateNotebookDialog() {
              showDialog(
                context: context,
                builder: (innerContext) => AlertDialog(
                  title: const Text('Create New Notebook'),
                  content: TextField(controller: newNotebookController, autofocus: true, decoration: const InputDecoration(labelText: 'Title')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(innerContext), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () async {
                        if (newNotebookController.text.trim().isNotEmpty) {
                          await _journalService.addNotebook(newNotebookController.text.trim(), 'assets/covers/1.jpg');
                          Navigator.pop(innerContext);
                          setDialogState(() {});
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              );
            }

            return FutureBuilder<List<JournalNotebook>>(
              future: _journalService.getNotebooks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const AlertDialog(content: Center(child: CircularProgressIndicator()));
                }

                final notebooks = snapshot.data!;
                if (notebooks.isNotEmpty && selectedNotebookId == null) {
                  selectedNotebookId = notebooks.first.id;
                }

                void saveEntry() {
                  if (selectedNotebookId == null) return;
                  final newEntry = JournalEntry.createNew(
                    notebookId: selectedNotebookId!,
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    images: null,
                  );
                  _journalService.addEntryToNotebook(selectedNotebookId!, newEntry);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry saved!')));
                }

                return AlertDialog(
                  title: const Text('Save to Journal'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCreatingNewNotebook)
                        DropdownButton<String>(
                          value: selectedNotebookId,
                          isExpanded: true,
                          hint: const Text('Select a Notebook'),
                          items: [
                            ...notebooks.map((n) => DropdownMenuItem(value: n.id, child: Text(n.title))).toList(),
                            const DropdownMenuItem(value: 'create_new', child: Text('+ Create New Notebook...')),
                          ],
                          onChanged: (value) {
                            if (value == 'create_new') {
                              showCreateNotebookDialog();
                            } else {
                              setDialogState(() {
                                selectedNotebookId = value;
                              });
                            }
                          },
                        ),
                      const SizedBox(height: 20),
                      TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                      const SizedBox(height: 16),
                      TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 4),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: selectedNotebookId == null ? null : saveEntry,
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          children: [
            // --- HEADER ---
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('YouMii', style: theme.textTheme.headlineSmall!.copyWith(color: theme.primaryColor)),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(icon: Icon(Icons.person, color: theme.primaryColor), onPressed: () {}),
              ),
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
                  return _DailyQuoteCard(quote: dailyQuote, onJournalTap: () => _showJournalPromptDialog(dailyQuote));
                }),

            const SizedBox(height: 20),

            // --- 2. MOOD LOG ---
            _MoodLogCard(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) => _showMoodNoteDialog(mood),
                onReset: () { setState(() { _selectedMood = null; }); }
            ),

            const SizedBox(height: 30),

            // --- 3. ACTIVITIES & PLANS ---
            Padding(padding: const EdgeInsets.only(left: 4.0, bottom: 12.0), child: Text('Wellness Tools', style: theme.textTheme.titleLarge)),

            _DailyProgressStrip(activities: _dailyActivities, cardColor: const Color(0xFFE0F2F1)),

            const SizedBox(height: 20),

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
  final VoidCallback onJournalTap;
  const _DailyQuoteCard({required this.quote, required this.onJournalTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: const Color(0xFF9EF0FF),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.format_quote_rounded, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 8),
              Text('Quote of the Day', style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Text('"${quote.text}"', style: theme.textTheme.titleMedium!.copyWith(height: 1.5)),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: Text('- ${quote.author}', style: theme.textTheme.bodySmall)),
            const SizedBox(height: 16),
            const Divider(color: Colors.black12),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onJournalTap,
                icon: Icon(Icons.book_outlined, color: theme.primaryColor),
                label: Text('Journal this', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ),
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

    // Color for the "Summary" state (When mood is already logged) - Kept Lavender/Periwinkle
    const summaryCardColor = Color(0xFFCCCCFF);

    // --- FIX: NEW COLOR FOR INPUT STATE ---

    const inputCardColor = Color(0xffFFAE25);
    // -------------------------------------

    // --- STATE 1: MOOD LOGGED (SUMMARY VIEW) ---
    if (selectedMood != null) {
      return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: summaryCardColor,
        child: InkWell(
          onTap: onReset,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: selectedMood!.color, width: 2),
                  ),
                  child: Text(selectedMood!.emoji, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mood Logged', style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey[700])),
                      Text(selectedMood!.label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Icon(Icons.edit, color: theme.primaryColor),
              ],
            ),
          ),
        ),
      );
    }

    // --- STATE 2: INPUT VIEW (Your Screenshot) ---
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: inputCardColor, // <--- APPLIED THE NEW YELLOW COLOR HERE
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'How do you feel today?',
                style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade700 // Changed text to brown for better contrast on yellow
                )
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MoodItem.allMoods.map((mood) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: InkWell(
                      onTap: () => onMoodSelected(mood),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white, // White background behind emojis to make them pop
                          border: Border.all(color: Colors.orange.withOpacity(0.1), width: 1),
                        ),
                        child: Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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

class _DailyTasksCard extends StatelessWidget {
  final List<String> tasks;
  final bool isLoading;
  final Color cardColor;
  const _DailyTasksCard({required this.tasks, required this.isLoading, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
    return Card(
      color: cardColor.withOpacity(0.25),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.eco, color: cardColor),
              const SizedBox(width: 8),
              const Text("Daily Plan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 12),
            ...tasks.map((task) => Padding(padding: const EdgeInsets.symmetric(vertical: 6.0), child: Row(children: [Icon(Icons.check_circle_outline, size: 20, color: cardColor), const SizedBox(width: 12), Expanded(child: Text(task, style: const TextStyle(fontSize: 15, color: Colors.black87)))]))).toList()
          ],
        ),
      ),
    );
  }
}