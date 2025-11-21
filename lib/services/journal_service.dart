// lib/services/journal_service.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_model.dart';
import 'dart:async';

class JournalService {
  static final JournalService _instance = JournalService._internal();
  factory JournalService() => _instance;

  JournalService._internal() {
    _notebooks = [
      JournalNotebook(id: 'daily', title: 'Daily Notes', icon: Icons.edit_note, createdAt: Timestamp.now(), color: Colors.blue, entryCount: 1),
      JournalNotebook(id: 'reflection', title: 'Self-Reflection', icon: Icons.self_improvement, createdAt: Timestamp.now(), color: Colors.purple, entryCount: 0),
    ];
    _entries = { 'daily': [ JournalEntry.createNew(notebookId: 'daily', title: 'First Entry', content: 'Welcome!') ] };
  }

  late List<JournalNotebook> _notebooks;
  late Map<String, List<JournalEntry>> _entries;

  Future<List<JournalNotebook>> getNotebooks() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _notebooks;
  }

  Future<void> addNotebook(String title) async {
    final newNotebook = JournalNotebook(
      id: 'notebook_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      icon: Icons.folder_outlined,
      createdAt: Timestamp.now(),
      color: Colors.deepOrange,
      entryCount: 0,
    );
    _notebooks.add(newNotebook);
    _entries[newNotebook.id] = [];
  }

  void addEntryToNotebook(String notebookId, JournalEntry newEntry) {
    if (!_entries.containsKey(notebookId)) _entries[notebookId] = [];
    _entries[notebookId]!.insert(0, newEntry);
  }

  // Other methods remain for other screens
  List<JournalEntry> getEntriesForNotebook(String notebookId) => _entries[notebookId] ?? [];
  void updateEntry(String notebookId, String entryId, String newTitle, String newContent) {}
  void deleteEntry(String notebookId, String entryId) {}
}