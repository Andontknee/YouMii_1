// lib/screens/home/notebooks_screen.dart

import 'package:flutter/material.dart';
import 'journal_list_screen.dart';

// Simple data model for a Notebook
class Notebook {
  final String title;
  final IconData icon;
  final String coverImageUrl;
  final int entryCount;

  Notebook({
    required this.title,
    required this.icon,
    required this.coverImageUrl,
    required this.entryCount,
  });
}

class NotebooksScreen extends StatefulWidget {
  const NotebooksScreen({super.key});

  @override
  State<NotebooksScreen> createState() => _NotebooksScreenState();
}

class _NotebooksScreenState extends State<NotebooksScreen> {
  // Placeholder data
  final List<Notebook> notebooks = [
    Notebook(title: 'Daily Notes', icon: Icons.edit_outlined, coverImageUrl: 'https://images.unsplash.com/photo-1544244015-0d1a74d455da?w=500', entryCount: 1),
    Notebook(title: 'Self-Reflection', icon: Icons.psychology_outlined, coverImageUrl: 'https://images.unsplash.com/photo-1508215892365-2a13c3593988?w=500', entryCount: 1),
    Notebook(title: 'Wellness', icon: Icons.favorite_border, coverImageUrl: 'https://images.unsplash.com/photo-1597854266932-0873a4b65b17?w=500', entryCount: 0),
    Notebook(title: 'Nutrition', icon: Icons.restaurant_menu, coverImageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=500', entryCount: 1),
  ];

  void _showCreateNotebookDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        // Use theme variables for colors
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text('New Notebook'),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter notebook title'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor))),
            ElevatedButton(
              onPressed: () {
                // TODO: Add logic to create a new notebook in Firebase
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- USING THEME VARIABLES ---
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Journals', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: GridView.builder(
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
            // This is the "Add New" card
            return InkWell(
              onTap: _showCreateNotebookDialog,
              borderRadius: BorderRadius.circular(15),
              child: Card(
                color: theme.cardColor, // Use cardColor for the box
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 40, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text('New Page', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            );
          }

          // These are the notebook cards
          final notebook = notebooks[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JournalListScreen(notebookTitle: notebook.title)),
              );
            },
            borderRadius: BorderRadius.circular(15),
            child: Card(
              color: theme.cardColor, // Use cardColor for the box
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.network(
                      notebook.coverImageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)), // Placeholder for missing image
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(notebook.icon, size: 16, color: theme.primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  notebook.title,
                                  style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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
      ),
    );
  }
}