// lib/services/journal_service.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_model.dart';
import 'dart:async';

class JournalService {
  static final JournalService _instance = JournalService._internal();
  factory JournalService() => _instance;

  JournalService._internal() {
    // Mock data initialization if needed
    _notebooks = [];
    _entries = {};
  }

  late List<JournalNotebook> _notebooks;
  late Map<String, List<JournalEntry>> _entries;

  Future<List<JournalNotebook>> getNotebooks() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _notebooks;
  }

  // UPDATED: Now requires an imagePath (either from assets or local storage)
  Future<void> addNotebook(String title, String imagePath) async {
    final newNotebook = JournalNotebook(
      id: 'notebook_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      icon: Icons.book,
      createdAt: Timestamp.now(),
      colorIndex: 0, // We ignore this now
      entryCount: 0,
      coverImagePath: imagePath, // SAVE THE PATH
    );
    _notebooks.add(newNotebook);
    _entries[newNotebook.id] = [];
  }

  Future<void> updateNotebook(String notebookId, String newTitle) async {
    final index = _notebooks.indexWhere((n) => n.id == notebookId);
    if (index != -1) {
      final old = _notebooks[index];
      _notebooks[index] = JournalNotebook(
        id: old.id,
        title: newTitle,
        icon: old.icon,
        createdAt: old.createdAt,
        colorIndex: old.colorIndex,
        entryCount: old.entryCount,
        isDeleted: old.isDeleted,
        deletedAt: old.deletedAt,
        coverImagePath: old.coverImagePath,
      );
    }
  }

  Future<void> deleteNotebook(String notebookId) async {
    _notebooks.removeWhere((n) => n.id == notebookId);
    _entries.remove(notebookId);
  }

  // --- Entry Methods ---

  void addEntryToNotebook(String notebookId, JournalEntry newEntry) {
    if (!_entries.containsKey(notebookId)) _entries[notebookId] = [];
    _entries[notebookId]!.insert(0, newEntry);
  }

  List<JournalEntry> getEntriesForNotebook(String notebookId) => _entries[notebookId] ?? [];

  void updateEntry(String notebookId, String entryId, String newTitle, String newContent, List<String>? newImages) {
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
          attachedImagePaths: newImages,
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