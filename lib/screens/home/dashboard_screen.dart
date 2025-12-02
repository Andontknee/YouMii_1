// lib/screens/home/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/content_hub/article.dart';
import 'article_reader_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Resources'),
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Support & Events', icon: Icon(Icons.people_outline)),
              Tab(text: 'Mindful Reading', icon: Icon(Icons.article_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Tab 1: Support, Events, Services
            _SupportAndCommunityTab(),

            // Tab 2: Dedicated Article Feed
            _ArticlesTab(),
          ],
        ),
      ),
    );
  }
}

// --- TAB 1: SUPPORT & COMMUNITY ---
class _SupportAndCommunityTab extends StatelessWidget {
  const _SupportAndCommunityTab();

  // --- UPDATED HELPER METHOD FOR EMERGENCY DIALOG ---
  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // --- FIX: Match Homepage Background Color ---
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent, // Removes any purple tint
        // --------------------------------------------
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
      trailing: IconButton(
        icon: const Icon(Icons.copy, color: Colors.blueGrey),
        tooltip: "Copy Number",
        onPressed: () {
          Clipboard.setData(ClipboardData(text: number));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name number copied to clipboard.')),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. EMERGENCY / HELPLINE CARD ---
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

          // --- 2. COMMUNITY EVENTS ---
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

          // --- 3. PROFESSIONAL SERVICES ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text('Find Support', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          const _ServiceTile(name: "Dr. Sarah Lim", role: "Clinical Psychologist", location: "Subang Jaya", icon: Icons.medical_services),
          const _ServiceTile(name: "Befrienders KL", role: "24/7 Emotional Support", location: "Petaling Jaya", icon: Icons.support_agent),
          const _ServiceTile(name: "Mindful Space", role: "Meditation Center", location: "Bangsar", icon: Icons.self_improvement),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// --- TAB 2: ARTICLES FEED ---
class _ArticlesTab extends StatelessWidget {
  const _ArticlesTab();

  @override
  Widget build(BuildContext context) {
    final CollectionReference articlesCollection =
    FirebaseFirestore.instance.collection('articles');

    return StreamBuilder<QuerySnapshot>(
      stream: articlesCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Error loading articles"));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final articles = snapshot.data!.docs.map((doc) => Article.fromFirestore(doc)).toList();

        if (articles.isEmpty) {
          return const Center(child: Text('No articles found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return _VerticalArticleCard(article: articles[index]);
          },
        );
      },
    );
  }
}

// --- WIDGETS ---

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
  final String name, role, location;
  final IconData icon;
  const _ServiceTile({required this.name, required this.role, required this.location, required this.icon});

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
        trailing: const Icon(Icons.phone, color: Colors.green),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling $name...')));
        },
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
        color: theme.cardColor,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Cover Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
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