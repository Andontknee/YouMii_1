// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- FIX IS HERE ---
  // We use the NAME of the variable in your .env file.
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  late final GenerativeModel _model;

  ChatService() {
    // : If 'gemini-2.5-flash' cannot work ah then, try 'gemini-1.5-flash'..why? idk its just like that
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  String _getSystemInstruction(String personality) {
    return "You are a helpful AI with a $personality personality.";
  }

  /// Analyzes a list of mood strings and returns a mental health insight
  Future<String> analyzeMoodTrend(List<String> last7DaysMoods) async {
    if (last7DaysMoods.isEmpty) {
      return "Log your moods for a few days to get an AI insight!";
    }

    final moodsString = last7DaysMoods.join(", ");
    final prompt = """
      You are an empathetic mental health companion. 
      The user's moods over the last 7 days were: [$moodsString].
      
      Please provide:
      1. A very brief analysis of their mental condition trend.
      2. One short, specific piece of actionable advice or a comforting word.
      Keep the total response under 40 words. Be warm and supportive.
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Unable to analyze at this moment.";
    } catch (e) {
      return "We couldn't reach the AI companion right now.";
    }
  }

  Future<String> createNewChat() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final docRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .add({
      'createdAt': FieldValue.serverTimestamp(),
      'title': 'New Chat',
    });
    return docRef.id;
  }

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

  Future<void> sendMessage(String conversationId, String text, bool isUser, {String? personality}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Save User Message
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

    // 2. Update Title if needed
    if (isUser) {
      final docRef = _firestore.collection('users').doc(user.uid).collection('conversations').doc(conversationId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists && docSnapshot.data()?['title'] == 'New Chat') {
        String newTitle = text.length > 30 ? "${text.substring(0, 30)}..." : text;
        await docRef.update({'title': newTitle});
      }
    }

    // 3. Generate AI Reply
    if (isUser) {
      try {
        final prompt = "${_getSystemInstruction(personality ?? 'Friend')}\n\nUser says: $text";
        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);
        final botReply = response.text ?? "I'm having trouble connecting.";

        await sendMessage(conversationId, botReply, false);
      } catch (e) {
        // If the error persists, print it to console to debug
        print("AI Error: $e");
        await sendMessage(conversationId, "I'm sorry, I encountered an error connecting to the brain.", false);
      }
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final WriteBatch batch = _firestore.batch();
    final docRef = _firestore.collection('users').doc(user.uid).collection('conversations').doc(conversationId);

    var messages = await docRef.collection('messages').get();
    for (var msg in messages.docs) {
      batch.delete(msg.reference);
    }
    batch.delete(docRef);

    await batch.commit();
  }
}