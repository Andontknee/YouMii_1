// lib/screens/home/journal_list_screen.dart

import 'package:flutter/material.dart';
import 'journal_entry_screen.dart'; // We will create this file next

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data - later this will come from Firebase
    final List<Map<String, String>> journalEntries = [
      {'title': 'A Great Day', 'date': 'October 28, 2025', 'description': 'Felt really positive and productive today...'},
      {'title': 'Morning Gratitude', 'date': 'October 27, 2025', 'description': 'Listed three things I am grateful for...'},
      {'title': 'Overcoming a Challenge', 'date': 'October 25, 2025', 'description': 'Faced a tough situation at work but handled...'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Journal', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month_outlined, color: Colors.grey[600]),
            onPressed: () {
              // TODO: Implement the simple calendar filter view
            },
            tooltip: 'View by Date',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: journalEntries.length,
        itemBuilder: (context, index) {
          final entry = journalEntries[index];
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              title: Text(
                entry['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('${entry['date']}\n${entry['description']}'),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JournalEntryScreen(isNewEntry: false)),
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
            MaterialPageRoute(builder: (context) => const JournalEntryScreen(isNewEntry: true)),
          );
        },
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}