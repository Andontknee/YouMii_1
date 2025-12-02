// lib/models/journal_model.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalNotebook {
  final String id;
  final String title;
  final IconData icon;
  final Timestamp createdAt;
  final bool isDeleted;
  final Timestamp? deletedAt;
  final int colorIndex;
  final int entryCount;
  final String? coverImagePath; // NEW: Stores local path to custom cover

  JournalNotebook({
    required this.id,
    required this.title,
    required this.icon,
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
    this.colorIndex = 0,
    required this.entryCount,
    this.coverImagePath, // Optional
  });

  factory JournalNotebook.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return JournalNotebook(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      icon: Icons.book_outlined,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: data['deletedAt'],
      colorIndex: data['colorIndex'] ?? 0,
      entryCount: data['entryCount'] ?? 0,
      coverImagePath: data['coverImagePath'], // Load path
    );
  }
}

class JournalEntry {
  final String id;
  final String notebookId;
  final String title;
  final String content;
  final String? mood;
  final Timestamp createdAt;
  final bool isDeleted;
  final Timestamp? deletedAt;
  final List<String>? attachedImagePaths; // NEW: List of images in entry

  JournalEntry({
    required this.id,
    required this.notebookId,
    required this.title,
    required this.content,
    this.mood,
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
    this.attachedImagePaths,
  });

  factory JournalEntry.createNew({required String notebookId, required String title, required String content, List<String>? images}) {
    return JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      notebookId: notebookId,
      title: title,
      content: content,
      createdAt: Timestamp.now(),
      attachedImagePaths: images,
    );
  }

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      notebookId: data['notebookId'] ?? '',
      title: data['title'] ?? 'Untitled Entry',
      content: data['content'] ?? '',
      mood: data['mood'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: data['deletedAt'],
      attachedImagePaths: List<String>.from(data['attachedImagePaths'] ?? []),
    );
  }
}