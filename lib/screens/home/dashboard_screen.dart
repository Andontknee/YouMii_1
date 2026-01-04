// lib/screens/home/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/content_hub/article.dart';
import '../../models/content_hub/quiz_model.dart';
import 'article_reader_screen.dart';
import 'quiz_screen.dart';

// --- CLASS 1: SUPPORT SCREEN ---
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Emergency Helplines'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelplineTile(context, "Emergency Services", "999"),
            const Divider(),
            _buildHelplineTile(context, "Befrienders KL", "03-76272929"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineTile(BuildContext context, String name, String number) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(number, style: const TextStyle(fontSize: 16, color: Colors.black87)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.green),
            onPressed: () async {
              final Uri launchUri = Uri(scheme: 'tel', path: number);
              if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.blueGrey),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: number));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name number copied.')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Support & Events'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. EMERGENCY
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: const Color(0xFFFFEBEE),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.red.shade200)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.phone_in_talk, color: Colors.red),
                  ),
                  title: const Text('Need help now?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  subtitle: const Text('Tap for helplines & SOS', style: TextStyle(color: Colors.red)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                  onTap: () => _showEmergencyDialog(context),
                ),
              ),
            ),

            // 2. COMMUNITY EVENTS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Community Events', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
                  Text('See All', style: TextStyle(color: theme.primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _CommunityEventCard(title: "Sunrise Yoga", location: "KLCC Park • 2km", date: "Nov 25", color: Colors.orange),
                  _CommunityEventCard(title: "Anxiety Support", location: "Online (Zoom)", date: "Nov 28", color: Colors.purple),
                  _CommunityEventCard(title: "Charity Walk", location: "Bukit Jalil", date: "Dec 01", color: Colors.green),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. SERVICES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text('Find Support', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            const _ServiceTile(name: "Dr. Sarah Lim", role: "Clinical Psychologist", location: "Subang Jaya", icon: Icons.medical_services, phoneNumber: "0355551234"),
            const _ServiceTile(name: "Befrienders KL", role: "24/7 Emotional Support", location: "Petaling Jaya", icon: Icons.support_agent, phoneNumber: "03-76272929"),
            const _ServiceTile(name: "Mindful Space", role: "Meditation Center", location: "Bangsar", icon: Icons.self_improvement, phoneNumber: "0320961222"),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- CLASS 2: READING SCREEN ---
class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  // --- FIX: REMOVED "text:" and "value:" labels ---
  List<Quiz> _getQuizzes() {
    return [
      Quiz(
        id: '1',
        title: 'Emotional Awareness',
        description: 'Check in with your feelings',
        icon: Icons.favorite_border,
        color: Colors.pinkAccent,
        questions: [
          QuizQuestion(
            question: "How are you feeling right now?",
            options: [
              // FIXED: Removed named parameters
              QuizOption("Calm & Content", "calm"),
              QuizOption("Anxious or Stressed", "stress"),
              QuizOption("Sad or Down", "sad"),
            ],
          ),
        ],
        results: [
          QuizResult(trait: "calm", title: "Balanced", description: "You are in a good headspace."),
          QuizResult(trait: "stress", title: "High Alert", description: "Consider taking a breathing break."),
          QuizResult(trait: "sad", title: "Gentle Care", description: "Be kind to yourself today."),
        ],
      ),
      Quiz(
        id: '2',
        title: 'Stress Level Test',
        description: 'Analyze your daily stress',
        icon: Icons.battery_alert,
        color: Colors.orangeAccent,
        questions: [
          QuizQuestion(
            question: "How overwhelmed do you feel?",
            options: [
              // FIXED: Removed named parameters
              QuizOption("Not at all", "low"),
              QuizOption("Very much", "high"),
            ],
          ),
        ],
        results: [
          QuizResult(trait: "low", title: "Low Stress", description: "You are managing well!"),
          QuizResult(trait: "high", title: "High Stress", description: "Time to decompress."),
        ],
      ),
      Quiz(
        id: '3',
        title: 'Personality Type',
        description: 'Are you Introverted?',
        icon: Icons.psychology,
        color: Colors.blueAccent,
        questions: [
          QuizQuestion(
            question: "Where do you recharge?",
            options: [
              // FIXED: Removed named parameters
              QuizOption("Alone", "introvert"),
              QuizOption("With people", "extrovert"),
            ],
          ),
        ],
        results: [
          QuizResult(trait: "introvert", title: "Introvert", description: "You gain energy from solitude."),
          QuizResult(trait: "extrovert", title: "Extrovert", description: "You gain energy from others."),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final CollectionReference articlesCollection = FirebaseFirestore.instance.collection('articles');
    final quizzes = _getQuizzes();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mindful Reading'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CAROUSEL
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Text("Discover Yourself", style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ),

          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                return _QuizCarouselCard(quiz: quizzes[index]);
              },
            ),
          ),

          const SizedBox(height: 20),

          // 2. ARTICLE LIST HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text("Latest Articles", style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),

          // 3. ARTICLE STREAM
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: articlesCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading articles"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final articles = snapshot.data!.docs.map((doc) => Article.fromFirestore(doc)).toList();

                if (articles.isEmpty) return const Center(child: Text('No articles found.'));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return _VerticalArticleCard(article: articles[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _QuizCarouselCard extends StatelessWidget {
  final Quiz quiz;
  const _QuizCarouselCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(quiz: quiz)));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: quiz.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: quiz.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child: Icon(quiz.icon, color: quiz.color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              quiz.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              quiz.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityEventCard extends StatelessWidget {
  final String title, location, date;
  final Color color;
  const _CommunityEventCard({required this.title, required this.location, required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Text(date, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(child: Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have joined the event!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 36)),
            child: const Text('Join', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String name, role, location, phoneNumber;
  final IconData icon;

  const _ServiceTile({required this.name, required this.role, required this.location, required this.icon, required this.phoneNumber});

  Future<void> _makePhoneCall(BuildContext context, String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$role • $location'),
        trailing: IconButton(
          icon: const Icon(Icons.phone, color: Colors.green),
          onPressed: () => _makePhoneCall(context, phoneNumber),
        ),
        onTap: () => _makePhoneCall(context, phoneNumber),
      ),
    );
  }
}

class _VerticalArticleCard extends StatelessWidget {
  final Article article;
  const _VerticalArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleReaderScreen(article: article))),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.black, width: 1)),
        margin: const EdgeInsets.only(bottom: 16.0),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.article, size: 50, color: theme.primaryColor),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator(color: theme.primaryColor.withOpacity(0.5)));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(article.category, style: TextStyle(color: theme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.title,
                    style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Read Article', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16, color: theme.primaryColor),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}