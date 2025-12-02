// lib/models/chat_message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser; // true if user sent it, false if AI sent it
  final Timestamp timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Convert Firestore document to Dart object
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      isUser: data['isUser'] ?? false,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convert Dart object to Map for saving
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp,
    };
  }
}