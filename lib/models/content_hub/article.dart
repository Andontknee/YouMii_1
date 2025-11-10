// lib/models/content_hub/article.dart (FINAL, DEFINITIVE Structure)

import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  // FINAL FIELDS (The actual properties of the Dart object)
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String fullContent;
  final String sourceName; // --- THIS IS THE CRITICAL MISSING FIELD ---

  Article({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.fullContent,
    required this.sourceName, // --- MUST BE IN THE CONSTRUCTOR ---
  });

  // Factory constructor to build the object from Firebase
  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Article(
      id: doc.id,
      title: data['title'] ?? 'Title Missing',
      category: data['category'] ?? 'General',
      imageUrl: data['imageUrl'] ?? 'NO_IMAGE',
      fullContent: data['full content'] ?? '## Content Missing in Firestore',
      sourceName: data['sourceName'] ?? 'YouMii Curated Insights', // <-- MAPPING FROM FIRESTORE
    );
  }
}