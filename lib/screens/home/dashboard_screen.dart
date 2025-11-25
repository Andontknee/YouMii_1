// lib/screens/home/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/content_hub/article.dart';
import 'article_reader_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final CollectionReference articlesCollection =
    FirebaseFirestore.instance.collection('articles');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Resources & Support'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. EMERGENCY / HELPLINE CARD ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: const Color(0xFFFFEBEE), // Light red/pink background
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
                  onTap: () {
                    // TODO: Show dialog with emergency numbers
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Call 999 or Befrienders KL: 03-76272929')));
                  },
                ),
              ),
            ),

            // --- 2. COMMUNITY EVENTS (Mocked) ---
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
              height: 160,
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

            // --- 3. PROFESSIONAL SERVICES (Mocked) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text('Find Support', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            const _ServiceTile(name: "Dr. Sarah Lim", role: "Clinical Psychologist", location: "Subang Jaya", icon: Icons.medical_services),
            const _ServiceTile(name: "Befrienders KL", role: "24/7 Emotional Support", location: "Petaling Jaya", icon: Icons.support_agent),

            const SizedBox(height: 30),

            // --- 4. MINDFUL ARTICLES (Firebase Driven) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mindful Articles', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
                  Text('See All', style: TextStyle(color: theme.primaryColor)),
                ],
              ),
            ),

            SizedBox(
              height: 240,
              child: StreamBuilder<QuerySnapshot>(
                stream: articlesCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final articles = snapshot.data!.docs.map((doc) => Article.fromFirestore(doc)).toList();

                  if (articles.isEmpty) return const Center(child: Text('No articles found.'));

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: articles.length,
                    itemBuilder: (context, index) => ArticleCard(article: articles[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
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
      width: 240,
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
      color: Theme.of(context).cardColor,
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
        onTap: () {},
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final Article article;
  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleReaderScreen(article: article))),
      child: Card(
        color: theme.cardColor,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(right: 16.0),
        child: SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- UPDATED IMAGE RENDERING ---
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    // Error builder in case URL is bad or 'NO_IMAGE'
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.article, size: 50, color: theme.primaryColor),
                    ),
                    // Loading builder for smooth UX
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(color: theme.primaryColor.withOpacity(0.5)));
                    },
                  ),
                ),
              ),
              // -------------------------------

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(article.category, style: TextStyle(color: theme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Text(article.title, style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}