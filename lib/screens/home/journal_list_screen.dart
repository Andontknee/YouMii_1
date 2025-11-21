// lib/screens/home/journal_list_screen.dart

import 'package:flutter/material.dart';
import 'journal_entry_screen.dart';
import '../../models/journal_model.dart';
import '../../services/journal_service.dart';

class JournalListScreen extends StatefulWidget {
  final JournalNotebook notebook;
  const JournalListScreen({super.key, required this.notebook});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  final JournalService _journalService = JournalService();
  late List<JournalEntry> _entries;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entries = _journalService.getEntriesForNotebook(widget.notebook.id);
    });
  }

  void _addNewEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEntryScreen(
          onSave: (title, content) {
            final newEntry = JournalEntry.createNew(
              notebookId: widget.notebook.id,
              title: title,
              content: content,
            );
            _journalService.addEntryToNotebook(widget.notebook.id, newEntry);
            _loadEntries(); // Refresh the list
          },
        ),
      ),
    );
  }

  void _editEntry(JournalEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEntryScreen(
          entry: entry,
          onSave: (title, content) {
            // FIX: Use the correct update method
            _journalService.updateEntry(widget.notebook.id, entry.id, title, content);
            _loadEntries(); // Refresh the list
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.year == date.year && now.month == date.month && now.day == date.day) return 'Today';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.notebook.title)),
      body: _entries.isEmpty
          ? const Center(child: Text('No entries yet.'))
          : ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return Dismissible(
            key: Key(entry.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _journalService.deleteEntry(widget.notebook.id, entry.id);
              _loadEntries(); // Refresh the list
            },
            child: ListTile(
              title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(entry.content, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Text(_formatDate(entry.createdAt.toDate())),
              onTap: () => _editEntry(entry),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}