// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart';
import 'notebooks_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';

// --- FIREBASE AND SERVICE IMPORTS ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/perma_prompt.dart';
import '/models/weather_forecast.dart';
import '/services/quote_service.dart';
// --- END SERVICE IMPORTS ---


// --- MOOD LOG DATA STRUCTURE ---
class MoodItem {
  final String emoji;
  final String label;
  final Color color;

  MoodItem(this.emoji, this.label, this.color);

  static final List<MoodItem> allMoods = [
    MoodItem('😀', 'Fantastic', Colors.green),
    MoodItem('😌', 'Calm', Colors.lightGreen), // New position, new label 'Calm'
    MoodItem('😔', 'Sad', Colors.orange), // Anxious -> Sad (simplified emotion)
    MoodItem('😭', 'Anxious', Colors.red), // Added Crying Emoji to separate sadness and anxiety visually
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
  TodayWeather? _weatherData;
  Quote? _dailyQuote;
  bool _isLoadingWeather = true;
  bool _isLoadingQuote = true;
  MoodItem? _selectedMood;

  @override
  void initState() {
    super.initState();
    // This now determines the PERMA category for the day
    _dailyPrompt = PermaPrompt.getRandomPrompt();
    _fetchWeather();
    _fetchQuote();
  }

  void _fetchWeather() async {
    final service = WeatherService();
    try {
      final data = await service.fetchWeatherData();
      if (mounted) {
        setState(() {
          _weatherData = data;
        });
      }
    } catch (e) {
      print('Error fetching weather: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
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

  // --- NEW FIREBASE SAVE FUNCTION ---
  Future<void> _saveMoodToFirebase(MoodItem mood) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Not logged in. Cannot save mood.')),
      );
      return;
    }

    final moodLogRef = FirebaseFirestore.instance.collection('mood_logs');
    final todayString = DateTime.now().toIso8601String().substring(0, 10); // Format YYYY-MM-DD

    try {
      // 1. Query for today's entry by user and date
      final querySnapshot = await moodLogRef
          .where('userId', isEqualTo: user.uid)
          .where('dateLogged', isEqualTo: todayString)
          .limit(1)
          .get();

      final moodData = {
        'userId': user.uid,
        'moodEmoji': mood.emoji,
        'moodLabel': mood.label,
        'timestamp': FieldValue.serverTimestamp(), // Firestore automatically records the server time
        'dateLogged': todayString, // Fixed format for easier querying
      };

      if (querySnapshot.docs.isNotEmpty) {
        // 2. If entry exists, update it
        await querySnapshot.docs.first.reference.update(moodData);
      } else {
        // 3. If entry doesn't exist, create it
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


  // --- UPDATED MOOD SELECTION LOGIC ---
  void _selectMood(MoodItem mood) {
    setState(() {
      final isNewSelection = _selectedMood != mood;
      _selectedMood = isNewSelection ? mood : null;

      if (_selectedMood != null) {
        _saveMoodToFirebase(_selectedMood!); // Save on successful selection
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Logic for weather-based suggestions
    String weatherSuggestion = 'Stay mindful and centered today.';
    bool showWeatherSuggestion = false;

    if (_weatherData != null && _weatherData!.currentTemp > 30) {
      weatherSuggestion = "The temperature is high. Remember to prioritize hydration and stay cool.";
      showWeatherSuggestion = true;
    }

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
            const SizedBox(height: 20),


            _isLoadingWeather
                ? const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ))
                : _UnifiedWeatherCard(data: _weatherData),
            const SizedBox(height: 20),

            if (showWeatherSuggestion)
              _SuggestionCard(text: weatherSuggestion, icon: Icons.waves_outlined),
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
            // --- FIX 1: Font Scaling Fix ---
            Text(
              selectedMood == null
                  ? 'How do you feel about your current emotions?'
                  : 'Mood Logged: ${selectedMood!.label}',
              style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold), // Reduced font size
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // --- FIX 2 & 3: Layout and Clipping Fix ---
            // Using a simple Row, and wrapping all items inside it.
            // Reduced emoji size from 40 to 30.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MoodItem.allMoods.map((mood) {
                final isSelected = mood == selectedMood;
                return Expanded( // Ensures emojis divide the space equally
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: InkWell(
                      onTap: () => onMoodSelected(mood),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4.0), // Reduced vertical padding
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
                          style: const TextStyle(fontSize: 32), // Reduced emoji size
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // End of clipping fix
          ],
        ),
      ),
    );
  }
}

class _UnifiedWeatherCard extends StatelessWidget {
  final TodayWeather? data;
  const _UnifiedWeatherCard({this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWarning = data != null && data!.warning.isNotEmpty;

    final backgroundColor = isWarning ? Colors.red.shade900 : Colors.blue.shade600;

    final location = data?.location ?? 'Kuala Lumpur';
    final temp = data?.currentTemp.toString() ?? '--';
    final condition = data?.condition ?? 'Partly Cloudy';
    final warning = data?.warning ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(location, style: theme.textTheme.titleMedium!.copyWith(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text('$temp°', style: theme.textTheme.displayLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.w300, height: 1.0)),
                  const SizedBox(height: 4),
                  Text(condition, style: theme.textTheme.titleMedium!.copyWith(color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(data?.icon ?? Icons.wb_sunny, color: Colors.yellowAccent, size: 28),
                  if (isWarning)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(warning, style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ],
              )
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white38),
          const SizedBox(height: 8),

          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data?.forecastStrip.length ?? 0,
              itemBuilder: (context, index) {
                final item = data!.forecastStrip[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(item.time, style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white70)),
                      Icon(item.icon, size: 24, color: Colors.white),
                      Text('${item.temp}°', style: theme.textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SuggestionCard({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge!.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}