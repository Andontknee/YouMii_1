// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _apiKey = "AIzaSyA9TbKqGXyNdnFqovfE7Lj3y-qpYcMlI6g";
  late final GenerativeModel _model;

  ChatService() {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  String _getSystemInstruction(String personality) {
    // ... (Keep your personality switch logic here) ...
    return "You are a helpful AI."; // Placeholder for brevity
  }

  // --- NEW: CONVERSATION MANAGEMENT ---

  // Create a new chat session
  Future<String> createNewChat() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final docRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .add({
      'createdAt': FieldValue.serverTimestamp(),
      'title': 'New Chat', // We can update this later with the first message
    });
    return docRef.id;
  }

  // Get list of all conversations for the Drawer
  Stream<QuerySnapshot> getConversations() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // --- MESSAGE MANAGEMENT ---

  // Get messages for a SPECIFIC conversation ID
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  // Send message to a SPECIFIC conversation
  Future<void> sendMessage(String conversationId, String text, bool isUser, {String? personality}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Save the message
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
      'text': text,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // If it's the first user message, update the Conversation Title
    if (isUser) {
      // Simple logic: use first 30 chars as title
      String title = text.length > 30 ? "${text.substring(0, 30)}..." : text;
      await _firestore.collection('users').doc(user.uid).collection('conversations').doc(conversationId).update({'title': title});
    }

    // If User sent it, trigger AI response
    if (isUser) {
      try {
        final prompt = "${_getSystemInstruction(personality ?? 'Friend')}\n\nUser says: $text";
        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);
        final botReply = response.text ?? "I'm having trouble connecting.";

        await sendMessage(conversationId, botReply, false); // Recursive call for bot
      } catch (e) {
        await sendMessage(conversationId, "Error: $e", false);
      }
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).collection('conversations').doc(conversationId).delete();
  }
}