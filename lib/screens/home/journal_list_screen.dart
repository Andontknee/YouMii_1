import 'package:flutter/material.dart';
import 'journal_entry_screen.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
      ),
      body: ListView.builder(
        itemCount: 5, // Replace with dynamic list from Firebase
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              title: Text('Journal Entry ${index + 1}'),
              subtitle: const Text('A brief summary of the entry...'),
              onTap: () {
                 Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JournalEntryScreen()),
                  );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JournalEntryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}