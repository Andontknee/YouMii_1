// lib/services/journal_service.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_model.dart';

// This service will now act as a mock/local service until we wire it to Firebase.
class JournalService {
  static final JournalService _instance = JournalService._internal();
  factory JournalService() => _instance;

  JournalService._internal() {
    _notebooks = [
      JournalNotebook(id: 'daily', title: 'Daily Notes', icon: Icons.edit_note, createdAt: Timestamp.now(), color: Colors.blue, entryCount: 2),
      JournalNotebook(id: 'reflection', title: 'Self-Reflection', icon: Icons.self_improvement, createdAt: Timestamp.now(), color: Colors.purple, entryCount: 1),
    ];
    _entries = {
      'daily': [
        JournalEntry.createNew(notebookId: 'daily', title: 'A Great Day', content: 'Felt productive and positive.'),
        JournalEntry.createNew(notebookId: 'daily', title: 'Learning Journey', content: 'Started learning Flutter.'),
      ],
      'reflection': [
        JournalEntry.createNew(notebookId: 'reflection', title: 'Personal Growth', content: 'Proud of my progress.'),
      ],
    };
  }

  late List<JournalNotebook> _notebooks;
  late Map<String, List<JournalEntry>> _entries;



  Future<List<JournalNotebook>> getNotebooks() async {
    // We simulate a network/database delay to correctly return a Future
    await Future.delayed(const Duration(milliseconds: 50));
    return _notebooks;
  }

  List<JournalEntry> getEntriesForNotebook(String notebookId) {
    return _entries[notebookId] ?? [];
  }

  // NEW, CORRECTED METHOD
  void addNotebook(String title) {
    final newNotebook = JournalNotebook(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      icon: Icons.folder_outlined,
      createdAt: Timestamp.now(),
      color: Colors.grey, // Default color
      entryCount: 0,
    );
    _notebooks.add(newNotebook);
    _entries[newNotebook.id] = [];
  }

  JournalNotebook? getNotebookById(String notebookId) {
    try {
      return _notebooks.firstWhere((n) => n.id == notebookId);
    } catch (e) {
      return null;
    }
  }

  void addEntryToNotebook(String notebookId, JournalEntry newEntry) {
    if (!_entries.containsKey(notebookId)) {
      _entries[notebookId] = [];
    }
    _entries[notebookId]!.insert(0, newEntry);
  }

  // FIX: Added the missing updateEntry method
  void updateEntry(String notebookId, String entryId, String newTitle, String newContent) {
    if (_entries.containsKey(notebookId)) {
      final index = _entries[notebookId]!.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        // Create a new entry object to replace the old one
        final oldEntry = _entries[notebookId]![index];
        _entries[notebookId]![index] = JournalEntry(
          id: oldEntry.id,
          notebookId: oldEntry.notebookId,
          title: newTitle,
          content: newContent,
          createdAt: oldEntry.createdAt,
        );
      }
    }
  }

  // FIX: Added the missing deleteEntry method
  void deleteEntry(String notebookId, String entryId) {
    if (_entries.containsKey(notebookId)) {
      _entries[notebookId]!.removeWhere((e) => e.id == entryId);
    }
  }
}