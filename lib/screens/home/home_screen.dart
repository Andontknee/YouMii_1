// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'journal_list_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';

// The main HomeScreen widget with the bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(), // The home screen content
    JournalListScreen(),
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
        backgroundColor: Colors.teal, // Brand color for FAB
        foregroundColor: Colors.white,
        elevation: 2.0,
        child: const Icon(Icons.hub_outlined), // Using a different icon for the AI
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white, // Light color for the nav bar
        elevation: 10.0, // Add a bit of shadow
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(icon: Icons.home, index: 0, label: 'Home'),
              _buildNavItem(icon: Icons.book_outlined, index: 1, label: 'Journal'), // Changed icon
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
        color: _selectedIndex == index ? Colors.teal : Colors.grey[500],
      ),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }
}


// --- THE HOME SCREEN CONTENT, NOW IN A LIGHT THEME ---
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Soft light grey background
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YouMii Ai',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.history_outlined, color: Colors.grey[600]),
                  onPressed: () { /* TODO: Implement chat history view */ },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Welcome Message
            const Text(
              'Welcome, Anthony',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Weather Card
            const _WeatherCard(),
            const SizedBox(height: 20),

            // AI Suggestion Card
            const _SuggestionCard(
              text: "Today's weather is slightly hotter than usual, may I remind you to drink more water?",
            ),
            const SizedBox(height: 20),

            // Activity Suggestion Card
            const _ActivityCard(),
          ],
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS WITH LIGHT THEME COLORS ---

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              Text('Now', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              const SizedBox(height: 8),
              const Text('35 °C', style: TextStyle(color: Colors.black, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Passing clouds', style: TextStyle(color: Colors.black87, fontSize: 16)),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.teal, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800], fontSize: 16, height: 1.5),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_run_outlined, color: Colors.teal, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'May I suggest some activities for later in the evening?',
                  style: TextStyle(color: Colors.grey[800], fontSize: 16, height: 1.5),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.teal.withOpacity(0.2))
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
      ),
    );
  }
}