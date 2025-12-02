// lib/screens/home/journal_list_screen.dart

import 'package:flutter/material.dart';
import 'journal_entry_screen.dart';
import '../../models/journal_model.dart';
import '../../services/journal_service.dart';
import 'package:intl/intl.dart';

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
      _entries = List.from(_journalService.getEntriesForNotebook(widget.notebook.id));
    });
  }

  void _addNewEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEntryScreen(
          // FIX: Added 'images' to the callback
          onSave: (title, content, images) {
            final newEntry = JournalEntry.createNew(
              notebookId: widget.notebook.id,
              title: title,
              content: content,
              images: images, // Pass images to creation
            );
            _journalService.addEntryToNotebook(widget.notebook.id, newEntry);
            _loadEntries();
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
          // FIX: Added 'images' to the callback
          onSave: (title, content, images) {
            _journalService.updateEntry(widget.notebook.id, entry.id, title, content, images);
            _loadEntries();
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.year == date.year && now.month == date.month && now.day == date.day) return 'Today';
    return DateFormat.yMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(widget.notebook.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),

      body: _entries.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Page is empty.', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];

          final Color rowColor = index % 2 == 0
              ? const Color(0xFFDBD1ED)
              : const Color(0xFFABBEED);

          return Dismissible(
            key: Key(entry.id),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _journalService.deleteEntry(widget.notebook.id, entry.id);
              setState(() {
                _entries.removeAt(index);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${entry.title}" deleted')),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: rowColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                    entry.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.content.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          entry.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    // Show icon if images are attached
                    if (entry.attachedImagePaths != null && entry.attachedImagePaths!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(children: [Icon(Icons.image, size: 14, color: Colors.black45), SizedBox(width: 4), Text("Image attached", style: TextStyle(fontSize: 10, color: Colors.black45))]),
                      )
                  ],
                ),
                trailing: Text(
                  _formatDate(entry.createdAt.toDate()),
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
                onTap: () => _editEntry(entry),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEntry,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}