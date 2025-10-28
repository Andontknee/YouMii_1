// lib/screens/home/journal_entry_screen.dart

import 'package:flutter/material.dart';

// --- Data Models for our Blocks ---
// A base class for all block types
abstract class JournalBlock {
  final int id;
  JournalBlock(this.id);
}

class TextBlock extends JournalBlock {
  String text;
  TextBlock(int id, {this.text = ''}) : super(id);
}

class TodoBlock extends JournalBlock {
  String text;
  bool isCompleted;
  TodoBlock(int id, {this.text = '', this.isCompleted = false}) : super(id);
}

class HeaderBlock extends JournalBlock {
  String text;
  HeaderBlock(int id, {this.text = ''}) : super(id);
}
// --- End of Data Models ---

class JournalEntryScreen extends StatefulWidget {
  final bool isNewEntry;
  const JournalEntryScreen({super.key, required this.isNewEntry});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _titleController = TextEditingController(text: 'A Great Day');
  final _descriptionController = TextEditingController(text: 'Felt really positive and productive today...');

  // The list of blocks that make up our journal entry
  final List<JournalBlock> _blocks = [
    TextBlock(1, text: 'This is a sample paragraph. The user can type freely here, expressing their thoughts and feelings.'),
    HeaderBlock(2, text: 'Tasks for Tomorrow'),
    TodoBlock(3, text: 'Prepare for the morning meeting', isCompleted: true),
    TodoBlock(4, text: 'Go for a 15-minute walk'),
  ];

  void _addBlock(Type blockType) {
    setState(() {
      final newId = _blocks.isNotEmpty ? _blocks.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1 : 1;
      if (blockType == TextBlock) {
        _blocks.add(TextBlock(newId));
      } else if (blockType == TodoBlock) {
        _blocks.add(TodoBlock(newId));
      } else if (blockType == HeaderBlock) {
        _blocks.add(HeaderBlock(newId));
      }
    });
  }

  void _showAddBlockMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.text_fields_outlined),
              title: const Text('Text'),
              onTap: () {
                Navigator.pop(context);
                _addBlock(TextBlock);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_box_outlined),
              title: const Text('To-do List'),
              onTap: () {
                Navigator.pop(context);
                _addBlock(TodoBlock);
              },
            ),
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('Header'),
              onTap: () {
                Navigator.pop(context);
                _addBlock(HeaderBlock);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.isNewEntry ? 'New Entry' : 'Edit Entry', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add_outlined),
            onPressed: () {
              // TODO: Implement notification/reminder logic
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder feature coming soon!')));
            },
            tooltip: 'Set Reminder',
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              // TODO: Implement save to Firebase logic
              Navigator.pop(context);
            },
            tooltip: 'Save Entry',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _blocks.length + 1, // +1 for the header section
              itemBuilder: (context, index) {
                if (index == 0) {
                  // --- Header section with Title and Description ---
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(hintText: 'Entry Title', border: InputBorder.none),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          maxLines: null,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                          decoration: const InputDecoration(hintText: 'Add a description...', border: InputBorder.none),
                        ),
                      ],
                    ),
                  );
                }

                // --- Render the blocks ---
                final block = _blocks[index - 1];
                if (block is TextBlock) {
                  return TextFormField(
                    initialValue: block.text,
                    maxLines: null,
                    decoration: const InputDecoration(hintText: 'Type something...', border: InputBorder.none),
                  );
                }
                if (block is HeaderBlock) {
                  return TextFormField(
                    initialValue: block.text,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(hintText: 'Header', border: InputBorder.none),
                  );
                }
                if (block is TodoBlock) {
                  return CheckboxListTile(
                    value: block.isCompleted,
                    onChanged: (value) {
                      setState(() {
                        block.isCompleted = value!;
                      });
                    },
                    title: TextFormField(
                      initialValue: block.text,
                      decoration: const InputDecoration(hintText: 'To-do item', border: InputBorder.none),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          // --- The Add Block Toolbar ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                  onPressed: _showAddBlockMenu,
                  tooltip: 'Add Block',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}