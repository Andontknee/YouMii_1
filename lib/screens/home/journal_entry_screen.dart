// lib/screens/home/journal_entry_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/journal_model.dart';

class JournalEntryScreen extends StatefulWidget {
  final JournalEntry? entry;
  // Updated callback signature to accept image path list
  final Function(String title, String content, List<String>? images) onSave;
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
  final ImagePicker _picker = ImagePicker();
  List<String> _attachedImages = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? widget.prefillContent);
    _attachedImages = widget.entry?.attachedImagePaths ?? [];
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _attachedImages.add(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickImage, // Trigger Image Picker
            tooltip: 'Attach Image',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(_titleController.text, _contentController.text, _attachedImages);
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

            // --- IMAGE PREVIEW STRIP ---
            if (_attachedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(_attachedImages[index]), width: 100, height: 100, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 0, top: 0,
                            child: InkWell(
                              onTap: () => setState(() => _attachedImages.removeAt(index)),
                              child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            // ---------------------------

            Expanded(
              child: TextField(
                controller: _contentController,
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