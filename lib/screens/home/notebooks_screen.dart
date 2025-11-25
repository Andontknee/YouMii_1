// lib/screens/home/notebooks_screen.dart

import 'package:flutter/material.dart';
import 'journal_list_screen.dart';
import '../../models/journal_model.dart';
import '../../services/journal_service.dart';

class NotebooksScreen extends StatefulWidget {
  const NotebooksScreen({super.key});

  @override
  State<NotebooksScreen> createState() => _NotebooksScreenState();
}

class _NotebooksScreenState extends State<NotebooksScreen> {
  final JournalService _journalService = JournalService();

  void _showAddOrEditNotebookDialog({JournalNotebook? notebook}) {
    final titleController = TextEditingController(text: notebook?.title ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notebook == null ? 'New Notebook' : 'Rename Notebook'),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter title'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty) {
                  if (notebook == null) {
                    await _journalService.addNotebook(titleController.text.trim());
                  } else {
                    await _journalService.updateNotebook(notebook.id, titleController.text.trim());
                  }
                  Navigator.pop(context);
                  setState(() {}); // Force rebuild
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(JournalNotebook notebook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notebook?'),
        content: Text('Are you sure you want to delete "${notebook.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _journalService.deleteNotebook(notebook.id);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We remove the Scaffold so it fits in the TabBar
    return Column(
      children: [
        // Add a header/add button here since we removed the AppBar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showAddOrEditNotebookDialog(),
                icon: const Icon(Icons.add),
                label: const Text('New Notebook'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<JournalNotebook>>(
            future: _journalService.getNotebooks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No journals yet. Create one!'));
              }

              final notebooks = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: notebooks.length,
                itemBuilder: (context, index) {
                  final notebook = notebooks[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JournalListScreen(notebook: notebook)),
                      );
                    },
                    onLongPress: () {
                      _showAddOrEditNotebookDialog(notebook: notebook);
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.book, size: 40, color: Colors.grey))),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notebook.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}