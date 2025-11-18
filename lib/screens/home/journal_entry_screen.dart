// lib/screens/home/journal_entry_screen.dart

import 'package:flutter/material.dart';
import '../../models/journal_model.dart';

class JournalEntryScreen extends StatefulWidget {
  final JournalEntry? entry;
  final Function(String title, String content) onSave;
  final String prefillContent;

  const JournalEntryScreen({
    super.key,
    this.entry,
    required this.onSave,
    this.prefillContent = '',
  });

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? widget.prefillContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(_titleController.text, _contentController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration.collapsed(hintText: 'Title...'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentController,
                autofocus: true,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration.collapsed(hintText: 'Start writing...'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}