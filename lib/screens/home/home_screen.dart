// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'notebooks_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';

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
    // --- Now using the global Scaffold background color ---
    return Scaffold(
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
        backgroundColor: Theme.of(context).primaryColor, // Use the lavender primary color
        foregroundColor: Colors.white,
        elevation: 2.0,
        child: const Icon(Icons.hub_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Theme.of(context).cardColor, // Use the card color for the nav bar surface
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


// --- THE HOME SCREEN CONTENT (ADAPTED TO THEME) ---
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            const _DailyFocusCard(),
            const SizedBox(height: 20),
            const _WeatherCard(),
            const SizedBox(height: 20),
            const _SuggestionCard(
              text: "Today's weather is slightly hotter than usual, may I remind you to drink more water?",
            ),
            const SizedBox(height: 20),
            const _ActivityCard(),
          ],
        ),
      ),
    );
  }
}

// --- NEW WIDGETS (ADAPTED TO THEME) ---
class _DailyFocusCard extends StatelessWidget {
  const _DailyFocusCard();

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
            Row(
              children: [
                Icon(Icons.psychology_outlined, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Daily Focus: Gratitude',
                  style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Pause now and intentionally list one small thing you are genuinely grateful for today.",
              style: theme.textTheme.titleLarge!.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Focus added to journal!')));
                },
                icon: Icon(Icons.book_outlined, color: theme.primaryColor),
                label: Text('Journal it Now', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
            )
          ]
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Now', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
              const SizedBox(height: 8),
              const Text('35 °C', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Passing clouds', style: TextStyle(fontSize: 16)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 80),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String text;
  const _SuggestionCard({required this.text});

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
          Icon(Icons.auto_awesome, color: theme.primaryColor, size: 24),
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

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_run_outlined, color: theme.primaryColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'May I suggest some activities for later in the evening?',
                  style: theme.textTheme.bodyLarge!.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: const [
              _ActivityChip(label: 'Cycling'),
              _ActivityChip(label: 'Stretching'),
              _ActivityChip(label: 'Yoga'),
              _ActivityChip(label: '10 minute walk'),
              _ActivityChip(label: 'Podcast'),
              _ActivityChip(label: 'Reading'),
            ],
          )
        ],
      ),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  final String label;
  const _ActivityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.primaryColor.withOpacity(0.4))
      ),
      child: Text(
        label,
        style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500),
      ),
    );
  }
}