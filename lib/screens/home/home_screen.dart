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
import '../sessions/breathing_session.dart';
import '../sessions/yoga_selection.dart';

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
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),
    const NotebooksScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];
  void _onItemTapped(int index) { setState(() { _selectedIndex = index; }); }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen())),
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
              _buildNavItem(icon: Icons.book_outlined, index: 1, label: 'Journal'),
              const SizedBox(width: 40),
              _buildNavItem(icon: Icons.analytics_outlined, index: 2, label: 'Dashboard'),
              _buildNavItem(icon: Icons.person_outline, index: 3, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildNavItem({required IconData icon, required int index, required String label}) {
    return IconButton(
      icon: Icon(icon, color: _selectedIndex == index ? Theme.of(context).primaryColor : Colors.grey[600]),
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
  MoodItem? _selectedMood;
  final List<Activity> _dailyActivities = Activity.defaultActivities;
  final JournalService _journalService = JournalService();

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  void _fetchQuote() {
    setState(() {
      _dailyQuoteFuture = QuoteService().fetchDailyQuote();
    });
  }

  Future<void> _saveMoodToFirebase(MoodItem mood) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Testing Mode: Not logged in.')));
      return;
    }
    final moodLogRef = FirebaseFirestore.instance.collection('mood_logs');
    final todayString = DateTime.now().toIso8601String().substring(0, 10);
    try {
      final querySnapshot = await moodLogRef.where('userId', isEqualTo: user.uid).where('dateLogged', isEqualTo: todayString).limit(1).get();
      final moodData = {'userId': user.uid, 'moodEmoji': mood.emoji, 'moodLabel': mood.label, 'timestamp': FieldValue.serverTimestamp(), 'dateLogged': todayString,};
      if (querySnapshot.docs.isNotEmpty) { await querySnapshot.docs.first.reference.update(moodData); } else { await moodLogRef.add(moodData); }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mood "${mood.label}" saved!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save mood.')));
      print("Firebase Mood Log Error: $e");
    }
  }

  void _selectMood(MoodItem mood) {
    setState(() {
      _selectedMood = _selectedMood == mood ? null : mood;
      if (_selectedMood != null) _saveMoodToFirebase(_selectedMood!);
    });
  }

  void _showJournalPromptDialog(Quote quote) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: JournalSaveDialog(quote: quote, journalService: _journalService)
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Text('Welcome, Anthony', style: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            FutureBuilder<Quote>(
                future: _dailyQuoteFuture,
                builder: (context, quoteSnapshot) {
                  if (quoteSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: LinearProgressIndicator()));
                  }
                  if (!quoteSnapshot.hasData) {
                    return const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Could not load daily quote.")));
                  }
                  final dailyQuote = quoteSnapshot.data!;
                  return _DailyQuoteCard(
                    quote: dailyQuote,
                    onJournalTap: () => _showJournalPromptDialog(dailyQuote),
                  );
                }
            ),
            const SizedBox(height: 20),
            _MoodLogCard(selectedMood: _selectedMood, onMoodSelected: _selectMood),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Text('Activities', style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
            ),
            _DailyProgressStrip(activities: _dailyActivities),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class JournalSaveDialog extends StatefulWidget {
  final Quote quote;
  final JournalService journalService;
  const JournalSaveDialog({required this.quote, required this.journalService, super.key});

  @override
  State<JournalSaveDialog> createState() => _JournalSaveDialogState();
}

class _JournalSaveDialogState extends State<JournalSaveDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _newNotebookController = TextEditingController();
  String? _selectedNotebookId;
  bool _isCreatingNewNotebook = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: "Reflection on a Quote");
    _contentController = TextEditingController(text: '"${widget.quote.text}"\n- ${widget.quote.author}\n\nMy reflection on this:\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<JournalNotebook>>(
      future: widget.journalService.getNotebooks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final notebooks = snapshot.data!;
        if (notebooks.isNotEmpty && _selectedNotebookId == null) {
          _selectedNotebookId = notebooks.first.id;
        }
        void saveEntry() {
          if (_selectedNotebookId == null) return;
          final newEntry = JournalEntry.createNew(
            notebookId: _selectedNotebookId!,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
          );
          widget.journalService.addEntryToNotebook(_selectedNotebookId!, newEntry);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry Saved!')));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Save to Journal', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            if (!_isCreatingNewNotebook)
              DropdownButton<String>(
                value: _selectedNotebookId,
                isExpanded: true,
                hint: const Text('Select a Notebook'),
                items: [
                  ...notebooks.map((n) => DropdownMenuItem(value: n.id, child: Text(n.title))),
                  const DropdownMenuItem(value: 'create_new', child: Text('+ Create New Notebook...')),
                ],
                onChanged: (value) {
                  if (value == 'create_new') {
                    setState(() => _isCreatingNewNotebook = true);
                  } else {
                    setState(() => _selectedNotebookId = value);
                  }
                },
              ),
            if (_isCreatingNewNotebook)
              Row(
                children: [
                  Expanded(child: TextField(controller: _newNotebookController, autofocus: true, decoration: const InputDecoration(labelText: 'New Folder Name'))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _isCreatingNewNotebook = false)),
                  IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        if (_newNotebookController.text.isNotEmpty) {
                          await widget.journalService.addNotebook(_newNotebookController.text.trim());
                          setState(() { _isCreatingNewNotebook = false; });
                        }
                      }
                  ),
                ],
              ),
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 16),
            Expanded(child: TextField(controller: _contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: null, expands: true, textAlignVertical: TextAlignVertical.top)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedNotebookId == null || _isCreatingNewNotebook ? null : saveEntry,
                  child: const Text('Save'),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

class _DailyQuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback onJournalTap;
  const _DailyQuoteCard({required this.quote, required this.onJournalTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.format_quote_outlined, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Quote of the Day', style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[400])),
            ]),
            const SizedBox(height: 12),
            Text('"${quote.text}"', style: theme.textTheme.titleMedium!.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('- ${quote.author}', style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey[500])),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onJournalTap,
                icon: Icon(Icons.book_outlined, color: theme.primaryColor),
                label: Text('Journal this Thought', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
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
  const _MoodLogCard({required this.selectedMood, required this.onMoodSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(selectedMood == null ? 'How do you feel about your current emotions?' : 'Mood Logged: ${selectedMood!.label}', style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MoodItem.allMoods.map((mood) {
                final isSelected = mood == selectedMood;
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
                          border: isSelected ? Border.all(color: theme.primaryColor, width: 3) : null,
                          color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
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
                if (activity.title == 'Yoga') {
                  sessionScreen = const YogaSelection();
                } else if (activity.title == 'Breathing') {
                  sessionScreen = BreathingSession(activity: activity);
                }
                if (sessionScreen != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => sessionScreen!));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${activity.title} session is coming soon!')));
                }
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(activity.icon, size: 32, color: activity.color),
                    Text(activity.title, style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                    Text('${activity.totalTimeMinutes} min', style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey[500])),
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