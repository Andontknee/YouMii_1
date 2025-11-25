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

  // Fetch Notebooks
  Future<List<JournalNotebook>> getNotebooks() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _notebooks;
  }

  // Add Notebook
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

  // --- MISSING METHODS RESTORED BELOW ---

  // Update Notebook Title
  Future<void> updateNotebook(String notebookId, String newTitle) async {
    final index = _notebooks.indexWhere((n) => n.id == notebookId);
    if (index != -1) {
      final old = _notebooks[index];
      // Create a new object with the updated title
      _notebooks[index] = JournalNotebook(
        id: old.id,
        title: newTitle,
        icon: old.icon,
        createdAt: old.createdAt,
        color: old.color,
        entryCount: old.entryCount,
        isDeleted: old.isDeleted,
        deletedAt: old.deletedAt,
      );
    }
  }

  // Delete Notebook
  Future<void> deleteNotebook(String notebookId) async {
    _notebooks.removeWhere((n) => n.id == notebookId);
    _entries.remove(notebookId);
  }

  // ---------------------------------------

  void addEntryToNotebook(String notebookId, JournalEntry newEntry) {
    if (!_entries.containsKey(notebookId)) _entries[notebookId] = [];
    _entries[notebookId]!.insert(0, newEntry);
  }

  List<JournalEntry> getEntriesForNotebook(String notebookId) => _entries[notebookId] ?? [];

  void updateEntry(String notebookId, String entryId, String newTitle, String newContent) {
    if (_entries.containsKey(notebookId)) {
      final index = _entries[notebookId]!.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        final oldEntry = _entries[notebookId]![index];
        _entries[notebookId]![index] = JournalEntry(
          id: oldEntry.id,
          notebookId: oldEntry.notebookId,
          title: newTitle,
          content: newContent,
          createdAt: oldEntry.createdAt,
          mood: oldEntry.mood,
        );
      }
    }
  }

  void deleteEntry(String notebookId, String entryId) {
    if (_entries.containsKey(notebookId)) {
      _entries[notebookId]!.removeWhere((e) => e.id == entryId);
    }
  }
}