// lib/screens/home/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../models/content_hub/article.dart';
import 'article_reader_screen.dart';
import 'home_screen.dart'; // Import to access MoodItem list

// --- MOOD SERVICE (Self-contained in this file) ---
class MoodService {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference _moodCollection =
  FirebaseFirestore.instance.collection('mood_logs');

  // Fetches a Map: {YYYY-MM-DD: MoodEmoji}
  Future<Map<String, String>> fetchMonthlyMoods(DateTime month) async {
    if (user == null) return {};

    // Get moods from today to the first day of the displayed month (reverse chron)
    final startOfMonth = DateTime(month.year, month.month, 1).toIso8601String().substring(0, 10);
    final endOfMonth = DateTime(month.year, month.month + 1, 0).toIso8601String().substring(0, 10);

    final snapshot = await _moodCollection
        .where('userId', isEqualTo: user!.uid)
        .where('dateLogged', isGreaterThanOrEqualTo: startOfMonth)
        .where('dateLogged', isLessThanOrEqualTo: endOfMonth)
        .get();

    final Map<String, String> moodMap = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final dateKey = data['dateLogged'];
      final emoji = data['moodEmoji'];
      if (dateKey != null && emoji != null) {
        moodMap[dateKey] = emoji;
      }
    }
    return moodMap;
  }
}
// --- END MOOD SERVICE ---

// --- WIDGETS ---

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Reference to the Firestore 'articles' collection
  final CollectionReference _articlesCollection =
  FirebaseFirestore.instance.collection('articles');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // We will refresh the entire screen (the Tabs) when they are clicked
    final moodCalendarView = MoodCalendarView(key: UniqueKey());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Resource Hub', style: TextStyle(color: Colors.white)),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(icon: Icon(Icons.psychology_outlined), text: 'Resources'),
                Tab(icon: Icon(Icons.calendar_today_outlined), text: 'Mood History'),
              ],
              labelColor: theme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.primaryColor,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Articles
                  _buildResourceTabView(context),
                  // Tab 2: The Mood Calendar - FIX: UniqueKey forces rebuild on navigation
                  moodCalendarView,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build the Resources Tab content (Articles)
  Widget _buildResourceTabView(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mindful Articles', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: Text('See All', style: TextStyle(color: theme.primaryColor)),
                ),
              ],
            ),
          ),

          // Article Stream Builder
          SizedBox(
            height: 280,
            child: StreamBuilder<QuerySnapshot>(
              stream: _articlesCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) { return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red))); }
                if (snapshot.connectionState == ConnectionState.waiting) { return const Center(child: CircularProgressIndicator()); }

                final articles = snapshot.data!.docs
                    .map((doc) => Article.fromFirestore(doc))
                    .toList();

                if (articles.isEmpty) { return Center(child: Text('No articles found.', style: TextStyle(color: Colors.grey[600]))); }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return ArticleCard(article: articles[index]);
                  },
                );
              },
            ),
          ),

          // Analytics Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text('Your Analytics', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'Basic Analytics and Progress coming soon!\nLog your mood to fill this space.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- NEW WIDGET: The Mood Calendar View (Now functional) ---
class MoodCalendarView extends StatefulWidget {
  // We use Key here so that the parent can pass a new key to force a rebuild/refresh.
  const MoodCalendarView({super.key});

  @override
  State<MoodCalendarView> createState() => _MoodCalendarViewState();
}

class _MoodCalendarViewState extends State<MoodCalendarView> {
  DateTime _displayMonth = DateTime.now();
  Map<String, String> _moodsByDate = {}; // {YYYY-MM-DD: MoodEmoji}
  final MoodService _moodService = MoodService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoods();
  }

  @override
  void didUpdateWidget(covariant MoodCalendarView oldWidget) {
    // Crucial to detect when a parent rebuilds with a new Key (i.e., when HomeContent saves data)
    if (widget.key != oldWidget.key) {
      _fetchMoods();
    }
    super.didUpdateWidget(oldWidget);
  }


  void _fetchMoods() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final moods = await _moodService.fetchMonthlyMoods(_displayMonth);
      if (mounted) {
        setState(() {
          _moodsByDate = moods;
        });
      }
    } catch (e) {
      print("Error fetching calendar moods: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Utility to get color/emoji based on the database data ---
  MoodItem _getMoodDetails(String emoji) {
    try {
      return MoodItem.allMoods.firstWhere((item) => item.emoji == emoji);
    } catch (_) {
      return MoodItem('🤷', 'Unknown', Colors.grey);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalDays = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    // Weekday is 1 (Mon) - 7 (Sun), we adjust for a Mon start
    final firstDayWeekday = DateTime(_displayMonth.year, _displayMonth.month, 1).weekday;

    final monthYearTitle = DateFormat('MMMM yyyy').format(_displayMonth);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Month/Year Header with navigations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  onPressed: () { setState(() { _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1); _fetchMoods(); }); }
              ),
              Text(
                monthYearTitle,
                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () { setState(() { _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1); _fetchMoods(); }); }
              ),
              // FIX: Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _fetchMoods,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Day Names Row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Mon', style: TextStyle(color: Colors.grey)), Text('Tue', style: TextStyle(color: Colors.grey)),
              Text('Wed', style: TextStyle(color: Colors.grey)), Text('Thu', style: TextStyle(color: Colors.grey)),
              Text('Fri', style: TextStyle(color: Colors.grey)), Text('Sat', style: TextStyle(color: Colors.grey)),
              Text('Sun', style: TextStyle(color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 8),

          // Calendar Grid
          _isLoading
              ? const Center(child: Padding(padding: EdgeInsets.only(top: 32), child: CircularProgressIndicator()))
              : Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemCount: totalDays + (firstDayWeekday - 1),
              itemBuilder: (context, index) {
                final dayOfMonth = index - (firstDayWeekday - 2);

                if (dayOfMonth < 1 || dayOfMonth > totalDays) {
                  return const SizedBox.shrink(); // Empty space
                }

                final dateKey = DateTime(_displayMonth.year, _displayMonth.month, dayOfMonth).toIso8601String().substring(0, 10);
                final emoji = _moodsByDate[dateKey];
                final moodDetail = emoji != null ? _getMoodDetails(emoji) : null;

                // Calendar Day Circle/Square
                return InkWell(
                  onTap: () {
                    // Optional: Navigate to an entry list for this day
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: moodDetail != null ? moodDetail.color.withOpacity(0.2) : Colors.transparent, // FIX: Use lightened color for day background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$dayOfMonth', style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 2),
                          if (emoji != null)
                          // FIX: Show a color dot instead of emoji for cleaner design (more like the inspiration)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: moodDetail!.color,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          Text('Mood Summary (Future Feature)', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}


// --- FIX: The Article Card Widget (Needed in this file for Resource Hub to work) ---
class ArticleCard extends StatelessWidget {
  final Article article;
  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArticleReaderScreen(article: article)),
        );
      },
      child: Card(
        color: theme.cardColor,
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.only(right: 16.0),
        child: SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder Image/Icon
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology_outlined, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),

                // Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    article.category,
                    style: theme.textTheme.labelSmall!.copyWith(color: Colors.grey[400], fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  article.title,
                  style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}