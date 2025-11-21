// lib/models/journal_model.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // FIX: Corrected import path

class JournalNotebook {
  final String id;
  final String title;
  final IconData icon;
  final Timestamp createdAt;
  final bool isDeleted;
  final Timestamp? deletedAt;
  final Color color; // FIX: Added color field
  final int entryCount; // FIX: Added entryCount field

  JournalNotebook({
    required this.id,
    required this.title,
    required this.icon,
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
    required this.color, // FIX: Added to constructor
    required this.entryCount, // FIX: Added to constructor
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
      color: Colors.grey, // FIX: Placeholder color
      entryCount: 0, // FIX: Placeholder count
    );
  }
}

class JournalEntry {
  final String id;
  final String notebookId;
  final String title;
  final String content;
  final String? mood; // ADDED: Mood field
  final Timestamp createdAt;
  final bool isDeleted;
  final Timestamp? deletedAt;

  JournalEntry({
    required this.id,
    required this.notebookId,
    required this.title,
    required this.content,
    this.mood, // ADDED: Mood field
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  // Helper method for creating new, un-saved entries (non-Firestore)
  factory JournalEntry.createNew({required String notebookId, required String title, required String content}) {
    return JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      notebookId: notebookId,
      title: title,
      content: content,
      createdAt: Timestamp.now(),
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
    );
  }
}