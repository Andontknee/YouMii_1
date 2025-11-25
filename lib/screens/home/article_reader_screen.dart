// lib/screens/home/article_reader_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/content_hub/article.dart';

class ArticleReaderScreen extends StatefulWidget {
  final Article article;
  const ArticleReaderScreen({super.key, required this.article});

  @override
  State<ArticleReaderScreen> createState() => _ArticleReaderScreenState();
}

class _ArticleReaderScreenState extends State<ArticleReaderScreen> {
  String _markdownContent = "";
  bool _isLoadingContent = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadFullContent();
  }

  void _loadFullContent() async {
    final docRef = FirebaseFirestore.instance.collection('articles').doc(widget.article.id);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final fullContent = data['full content'] as String? ?? 'Article content is missing. Please edit the full content field in Firebase.';

      if (mounted) {
        setState(() {
          _markdownContent = fullContent;
          _isLoadingContent = false;
        });
      }
    } else if (mounted) {
      setState(() {
        _markdownContent = "# Error: Article Content Not Found";
        _isLoadingContent = false;
      });
    }
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isSaved ? 'Article Saved!' : 'Article Unsaved.')),
      );
    });
  }

  void _onTapLink(String text, String? href, String title) async {
    if (href != null) {
      final url = Uri.parse(href);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link.')));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.article.title, style: theme.appBarTheme.titleTextStyle, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
            color: theme.primaryColor,
            onPressed: _toggleSave,
            tooltip: 'Save Article',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoadingContent
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // 1. Title/Header
          Text(widget.article.title, style: theme.textTheme.headlineMedium!.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // 2. Source Name
          Text("Source: ${widget.article.sourceName}", style: theme.textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic, color: Colors.grey)),
          const Divider(color: Colors.grey), // Changed from white12 to grey for visibility

          // 3. Main Markdown Content
          MarkdownBody(
            data: _markdownContent,
            selectable: true,
            onTapLink: _onTapLink,
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              // --- FIX: UPDATED COLORS FOR LIGHT THEME ---

              // Paragraphs: Use the theme's body text color (Dark Grey/Purple)
              p: theme.textTheme.bodyLarge!.copyWith(height: 1.6),

              // Headings: Use primary color or dark text
              h1: theme.textTheme.headlineSmall!.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
              h2: theme.textTheme.titleLarge!.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
              h3: theme.textTheme.titleMedium!.copyWith(color: Colors.black54, fontWeight: FontWeight.bold),

              // Links: Keep primary color
              a: TextStyle(color: theme.primaryColor, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),

              // Quotes: Grey italic
              blockquote: theme.textTheme.titleMedium!.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[600]),

              // Lists: Use dark bullets
              listBullet: TextStyle(color: Colors.black87, fontSize: theme.textTheme.bodyLarge!.fontSize),

              // Bold text
              strong: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'End of Article. Reflection is the start of change.',
              style: theme.textTheme.labelLarge!.copyWith(color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}