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
import 'journal_entry_screen.dart';
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
  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
  }
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
  // --- REMOVED PermaPrompt state ---
  Quote? _dailyQuote;
  bool _isLoadingQuote = true;
  MoodItem? _selectedMood;
  final List<Activity> _dailyActivities = Activity.defaultActivities;
  final JournalService _journalService = JournalService();

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  void _fetchQuote() async {
    final service = QuoteService();
    try {
      final quote = await service.fetchDailyQuote();
      if (mounted) setState(() { _dailyQuote = quote; });
    } catch (e) {
      print('Error fetching quote: $e');
    } finally {
      if (mounted) setState(() { _isLoadingQuote = false; });
    }
  }

  Future<void> _saveMoodToFirebase(MoodItem mood) async {
    // ... (This function remains correct and unchanged)
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
      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update(moodData);
      } else {
        await moodLogRef.add(moodData);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mood "${mood.label}" saved!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save mood.')));
      print("Firebase Mood Log Error: $e");
    }
  }

  void _selectMood(MoodItem mood) {
    // ... (This function remains correct and unchanged)
    setState(() {
      _selectedMood = _selectedMood == mood ? null : mood;
      if (_selectedMood != null) _saveMoodToFirebase(_selectedMood!);
    });
  }

  // --- DEFINITIVE NEW "JOURNAL IT NOW" DIALOG ---
  void _showJournalPromptDialog(Quote quote) {
    showDialog(
      context: context,
      builder: (context) {
        return _JournalSelectionDialog(
          quote: quote,
          journalService: _journalService,
        );
      },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('YouMii Ai', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.history_outlined, color: theme.iconTheme.color), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 30),
            Text('Welcome, Anthony', style: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            _isLoadingQuote
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: LinearProgressIndicator()))
                : _QuoteCard( // Renamed from _DailyFocusCard
              quote: _dailyQuote!,
              onJournalTap: () => _showJournalPromptDialog(_dailyQuote!),
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

// --- NEW DIALOG WIDGET (Clean and Self-Contained) ---
class _JournalSelectionDialog extends StatefulWidget {
  final Quote quote;
  final JournalService journalService;
  const _JournalSelectionDialog({required this.quote, required this.journalService});

  @override
  State<_JournalSelectionDialog> createState() => _JournalSelectionDialogState();
}

class _JournalSelectionDialogState extends State<_JournalSelectionDialog> {
  String? _selectedNotebookId;
  bool _isCreatingNew = false;
  final _newNotebookController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<JournalNotebook>>(
      future: widget.journalService.getNotebooks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AlertDialog(content: Center(child: CircularProgressIndicator()));
        }

        final notebooks = snapshot.data!;
        if (_selectedNotebookId == null && notebooks.isNotEmpty) {
          _selectedNotebookId = notebooks.first.id;
        }

        return AlertDialog(
          title: const Text('Save to Journal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isCreatingNew)
                DropdownButton<String>(
                  value: _selectedNotebookId,
                  isExpanded: true,
                  hint: const Text('Select a Notebook'),
                  items: [
                    ...notebooks.map((n) => DropdownMenuItem(value: n.id, child: Text(n.title))),
                    const DropdownMenuItem(value: 'create_new', child: Text('+ Create New Notebook...')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value == 'create_new') {
                        _isCreatingNew = true;
                      } else {
                        _selectedNotebookId = value;
                      }
                    });
                  },
                ),
              if (_isCreatingNew)
                Column(
                  children: [
                    TextField(controller: _newNotebookController, autofocus: true, decoration: const InputDecoration(labelText: 'New Folder Name')),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => setState(() => _isCreatingNew = false), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () async {
                            if (_newNotebookController.text.trim().isNotEmpty) {
                              await widget.journalService.addNotebook(_newNotebookController.text.trim());
                              // This will cause the FutureBuilder to refetch and update the dropdown
                              setState(() {
                                _isCreatingNew = false;
                              });
                            }
                          },
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: (_selectedNotebookId == null || _isCreatingNew) ? null : () {
                Navigator.pop(context); // Close dialog first
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JournalEntryScreen(
                      onSave: (title, content) {
                        final newEntry = JournalEntry.createNew(notebookId: _selectedNotebookId!, title: title, content: content);
                        widget.journalService.addEntryToNotebook(_selectedNotebookId!, newEntry);
                      },
                      // Prefill the new entry screen
                      prefillTitle: widget.quote.author,
                      prefillContent: '"${widget.quote.text}"\n\nMy reflection:\n',
                    ),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}

// --- RENAMED WIDGET: _QuoteCard ---
class _QuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback onJournalTap;
  const _QuoteCard({required this.quote, required this.onJournalTap});

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
        const SizedBox(height: 16),
        Text('"${quote.text}"', style: theme.textTheme.titleMedium!.copyWith(fontStyle: FontStyle.italic, height: 1.4)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text('- ${quote.author}', style: theme.textTheme.bodyMedium!.copyWith(color: Colors.grey[500])),
        ),
        const SizedBox(height: 16),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
                onPressed: onJournalTap,
                icon: Icon(Icons.book_outlined, color: theme.primaryColor),
                label: Text('Journal this Tho