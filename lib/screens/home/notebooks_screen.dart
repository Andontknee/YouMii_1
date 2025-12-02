// lib/screens/home/notebooks_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  // Your Default Library
  final List<String> _defaultCoverAssets = [
    'assets/covers/1.jpg',
    'assets/covers/2.jpg',
    'assets/covers/3.jpg',
    'assets/covers/4.jpg',
    'assets/covers/5.jpg',
    'assets/covers/6.jpg',
    'assets/covers/7.jpg',
    'assets/covers/8.jpg',
  ];

  // --- 1. RENAME / CREATE DIALOG ---
  void _showAddOrEditNotebookDialog({JournalNotebook? notebook}) {
    final titleController = TextEditingController(text: notebook?.title ?? '');
    String? selectedImagePath = notebook?.coverImagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {

            Future<void> pickImage() async {
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  selectedImagePath = image.path;
                });
              }
            }

            return AlertDialog(
              title: Text(notebook == null ? 'New Notebook' : 'Rename Notebook'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Enter title'),
                  ),
                  const SizedBox(height: 20),

                  InkWell(
                    onTap: pickImage,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: selectedImagePath != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImage(selectedImagePath!, BoxFit.cover),
                      )
                          : const Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Upload Cover (Optional)", style: TextStyle(color: Colors.grey))
                        ],
                      )),
                    ),
                  ),
                  if (selectedImagePath != null)
                    Center(child: TextButton(onPressed: () => setState(() => selectedImagePath = null), child: const Text("Remove Image", style: TextStyle(color: Colors.red)))),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isNotEmpty) {
                      if (notebook == null) {
                        String finalImage = selectedImagePath ?? _defaultCoverAssets[Random().nextInt(_defaultCoverAssets.length)];
                        await _journalService.addNotebook(titleController.text.trim(), finalImage);
                      } else {
                        await _journalService.updateNotebook(notebook.id, titleController.text.trim());
                      }
                      Navigator.pop(context);
                      // Force refresh the main screen
                      this.setState(() {});
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => setState(() {}));
  }

  // --- 2. DELETE CONFIRMATION DIALOG ---
  void _showDeleteConfirmDialog(JournalNotebook notebook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notebook?'),
        content: Text('Are you sure you want to delete "${notebook.title}"? All entries inside will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _journalService.deleteNotebook(notebook.id);
              Navigator.pop(context); // Close dialog
              setState(() {}); // Refresh screen to remove item
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- 3. OPTIONS MENU (The Fix) ---
  void _showNotebookOptions(JournalNotebook notebook) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename / Edit Cover'),
                onTap: () {
                  Navigator.pop(context); // Close menu
                  _showAddOrEditNotebookDialog(notebook: notebook); // Open Edit
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Notebook', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context); // Close menu
                  _showDeleteConfirmDialog(notebook); // Open Delete Confirm
                },
              ),
            ],
          );
        }
    );
  }

  Widget _buildImage(String path, BoxFit fit) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: fit, width: double.infinity, height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey, child: const Icon(Icons.broken_image, color: Colors.white)),
      );
    } else {
      return Image.file(File(path), fit: fit, width: double.infinity, height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey, child: const Icon(Icons.broken_image, color: Colors.white)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No journals yet. Create one!'));

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
                    // --- FIX: Calls the Options Menu instead of Edit Dialog directly ---
                    onLongPress: () => _showNotebookOptions(notebook),
                    // ------------------------------------------------------------------

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
                            child: notebook.coverImagePath != null
                                ? _buildImage(notebook.coverImagePath!, BoxFit.cover)
                                : Container(color: Colors.grey, child: const Center(child: Icon(Icons.book, size: 40, color: Colors.white))),
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
                                  const Spacer(),
                                  Text('${notebook.entryCount} entries', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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