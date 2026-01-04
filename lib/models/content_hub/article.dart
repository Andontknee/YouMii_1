// lib/models/content_hub/article.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  // FINAL FIELDS (The actual properties of the Dart object)
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String fullContent;
  final String sourceName;

  Article({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.fullContent,
    required this.sourceName,
  });

  // Factory constructor to build the object from Firebase
  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Article(
      id: doc.id,
      title: data['title'] ?? 'Title Missing',
      category: data['category'] ?? 'General',
      imageUrl: (data['imageURL'] ?? '').toString().trim(),
      fullContent: data['full content'] ?? '## Content Missing in Firestore',
      sourceName: data['sourceName'] ?? 'YouMii Curated Insights',
    );
  }
}