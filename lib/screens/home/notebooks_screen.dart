// lib/screens/home/notebooks_screen.dart

import 'package:flutter/material.dart'; // <<< FIX: MISSING IMPORT
import 'package:cloud_firestore/cloud_firestore.dart'; // <<< FIX: MISSING IMPORT
import 'package:firebase_auth/firebase_auth.dart'; // <<< FIX: MISSING IMPORT
import 'journal_list_screen.dart';
import '../../models/journal_model.dart';
import '/services/test_auth_service.dart'; // FIX: Path is now correct

class NotebooksScreen extends StatefulWidget {
  const NotebooksScreen({super.key});

  @override
  State<NotebooksScreen> createState() => _NotebooksScreenState();
}

class _NotebooksScreenState extends State<NotebooksScreen> {
  // --- CHANGE: Use the TestAuthService to get a non-null user for testing ---
  final User? _currentUser = TestAuthService.currentUser;

  // Now safe because _currentUser is a MockUser with a UID
  late final CollectionReference _notebooksCollection;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _notebooksCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('notebooks');
    }
  }

  // ... (The rest of the file remains the same, which is now safe to compile) ...

  void _showCreateNotebookDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Notebook'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., Daily Reflections'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                _notebooksCollection.add({
                  'title': titleController.text.trim(),
                  'description': '',
                  'entryCount': 0,
                  'isDeleted': false,
                  'deletedAt': null,
                  'createdAt': Timestamp.now(),
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _editNotebook(JournalNotebook notebook) {
    final titleController = TextEditingController(text: notebook.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Notebook'),
        content: TextField(controller: titleController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _notebooksCollection.doc(notebook.id).update({'title': titleController.text.trim()});
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteNotebook(JournalNotebook notebook) {
    // Soft delete
    _notebooksCollection.doc(notebook.id).update({
      'isDeleted': true,
      'deletedAt': Timestamp.now(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${notebook.title}" moved to trash.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            _notebooksCollection.doc(notebook.id).update({'isDeleted': false, 'deletedAt': null});
          },
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, JournalNotebook notebook) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(context);
              _editNotebook(notebook);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Move to Trash', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteNotebook(notebook);
            },
          ),
        ],
      ),
    );
  }
  // --- END of LOGIC ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Handle case where user is not logged in
    if (_currentUser == null) {
      return const Center(child: Text('Please log in to use the journal feature.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Journals', style: theme.appBarTheme.titleTextStyle),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notebooksCollection.where('isDeleted', isEqualTo: false).orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final notebooks = snapshot.data!.docs.map((doc) => JournalNotebook.fromFirestore(doc)).toList();

          if (notebooks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.library_books_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 24),
                    Text('No Journals Yet', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the button below to create your first journal notebook.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _showCreateNotebookDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Notebook'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.8,
            ),
            itemCount: notebooks.length + 1,
            itemBuilder: (context, index) {
              if (index == notebooks.length) {
                return InkWell(
                  onTap: _showCreateNotebookDialog,
                  borderRadius: BorderRadius.circular(15),
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('New Page', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final notebook = notebooks[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JournalListScreen(notebook: notebook)),
                  );
                },
                onLongPress: () {
                  _showContextMenu(context, notebook);
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
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey.shade800,
                          child: Icon(notebook.icon, size: 40, color: notebook.color),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notebook.title, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              const Spacer(),
                              Text('Entries: ${notebook.entryCount}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
    );
  }
}