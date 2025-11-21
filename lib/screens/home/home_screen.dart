// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'notebooks_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';

// --- FIREBASE AND SERVICE IMPORTS ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/perma_prompt.dart';
import '/services/quote_service.dart';
import '/models/activity_model.dart';

import '../sessions/breathing_session.dart';
import '../sessions/yoga_selection.dart';
import '../sessions/meditation_selection.dart';



// --- MOOD LOG DATA STRUCTURE ---
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
// --- END MOOD LOG DATA STRUCTURE ---


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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
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
      icon: Icon(
        icon,
        color: _selectedIndex == index ? Theme.of(context).primaryColor : Colors.grey[600],
      ),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }
}


// --- THE HOME SCREEN CONTENT, DYNAMIC AND STATEFUL ---
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late PermaPrompt _dailyPrompt;
  Quote? _dailyQuote;
  bool _isLoadingQuote = true;
  MoodItem? _selectedMood;
  final List<Activity> _dailyActivities = Activity.defaultActivities;

  @override
  void initState() {
    super.initState();
    _dailyPrompt = PermaPrompt.getRandomPrompt();
    _fetchQuote();
  }

  void _fetchQuote() async {
    final service = QuoteService();
    try {
      final quote = await service.fetchDailyQuote();
      if (mounted) {
        setState(() {
          _dailyQuote = quote;
        });
      }
    } catch (e) {
      print('Error fetching quote: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingQuote = false;
        });
      }
    }
  }

  Future<void> _saveMoodToFirebase(MoodItem mood) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Testing Mode: Not logged in. Cannot save mood.')),
      );
      return;
    }

    final moodLogRef = FirebaseFirestore.instance.collection('mood_logs');
    final todayString = DateTime.now().toIso8601String().substring(0, 10);

    try {
      final querySnapshot = await moodLogRef
          .where('userId', isEqualTo: user.uid)
          .where('dateLogged', isEqualTo: todayString)
          .limit(1)
          .get();

      final moodData = {
        'userId': user.uid,
        'moodEmoji': mood.emoji,
        'moodLabel': mood.label,
        'timestamp': FieldValue.serverTimestamp(),
        'dateLogged': todayString,
      };

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update(moodData);
      } else {
        await moodLogRef.add(moodData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mood "${mood.label}" logged and saved to history!')),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save mood. Check console for error.')),
      );
      print("Firebase Mood Log Error: $e");
    }
  }


  void _selectMood(MoodItem mood) {
    setState(() {
      _selectedMood = _selectedMood == mood ? null : mood;
      if (_selectedMood != null) {
        _saveMoodToFirebase(_selectedMood!);
      }
    });
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
                Text(
                  'YouMii Ai',
                  style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.history_outlined, color: theme.iconTheme.color),
                  onPressed: () { /* TODO: Implement chat history view */ },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Welcome, Anthony',
              style: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            _isLoadingQuote
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: LinearProgressIndicator()))
                : _DailyFocusCard(
              prompt: _dailyPrompt,
              quote: _dailyQuote!,
            ),
            const SizedBox(height: 20),

            _MoodLogCard(
              selectedMood: _selectedMood,
              onMoodSelected: _selectMood,
            ),
            const SizedBox(height: 40),


            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Text(
                'Activities',
                style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _DailyProgressStrip(
              activities: _dailyActivities,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


// --- WIDGETS ---

class _DailyFocusCard extends StatelessWidget {
  final PermaPrompt prompt;
  final Quote quote;
  const _DailyFocusCard({required this.prompt, required this.quote});

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
            Row(
              children: [
                Icon(Icons.psychology_outlined, color: theme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Daily Focus: ${prompt.title}',
                  style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prompt.prompt,
              style: theme.textTheme.titleMedium!.copyWith(fontStyle: FontStyle.normal),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journal link coming soon!')));
                },
                icon: Icon(Icons.book_outlined, color: theme.primaryColor),
                label: Text('Journal it Now', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            Text(
              '"${quote.text}"',
              style: theme.textTheme.bodyMedium!.copyWith(color: Colors.grey[400], fontStyle: FontStyle.italic),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('- ${quote.author}', style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey[500])),
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
            Text(
              selectedMood == null
                  ? 'How do you feel about your current emotions?'
                  : 'Mood Logged: ${selectedMood!.label}',
              style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
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
                          border: isSelected
                              ? Border.all(color: theme.primaryColor, width: 3)
                              : null,
                          color: isSelected
                              ? theme.primaryColor.withOpacity(0.1)
                              : null,
                        ),
                        child: Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
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

                // --- ROUTING LOGIC ---
                if (activity.title == 'Yoga') {
                  sessionScreen = const YogaSelection();
                } else if (activity.title == 'Breathing') {
                  sessionScreen = BreathingSession(activity: activity);
                } else if (activity.title == 'Meditation') {
                  sessionScreen = const MeditationSelectionScreen();
                }
                // --- END ROUTING LOGIC ---

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