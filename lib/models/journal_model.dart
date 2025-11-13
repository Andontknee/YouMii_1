// lib/models/journal_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JournalNotebook {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int entryCount;
  final Color color;
  final bool isDeleted;      // --- NEW FIELD ---
  final Timestamp? deletedAt; // --- NEW FIELD ---

  const JournalNotebook({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.entryCount,
    required this.color,
    this.isDeleted = false, // Default to not deleted
    this.deletedAt,
  });

  // Add a factory constructor for Firestore
  factory JournalNotebook.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalNotebook(
      id: doc.id,
      title: data['title'] ?? 'Untitled Notebook',
      description: data['description'] ?? '',
      // For simplicity, we'll keep icons local for now
      icon: Icons.book,
      entryCount: data['entryCount'] ?? 0,
      color: Colors.grey, // And color
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: data['deletedAt'] as Timestamp?,
    );
  }
}

class JournalEntry {
  final String id;
  final String notebookId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? mood;
  final bool isDeleted;      // --- NEW FIELD ---
  final Timestamp? deletedAt; // --- NEW FIELD ---

  JournalEntry({
    required this.id,
    required this.notebookId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.mood,
    this.isDeleted = false,
    this.deletedAt,
  });

  // (The rest of the JournalEntry class remains the same)
  factory JournalEntry.createNew({
    required String notebookId,
    required String title,
    required String content,
  }) {
    final now = DateTime.now();
    return JournalEntry(
      id: 'entry_${now.millisecondsSinceEpoch}',
      notebookId: notebookId,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }
}