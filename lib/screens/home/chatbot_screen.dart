// lib/screens/home/chatbot_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../models/chat_message_model.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key to open drawer

  String? _currentConversationId; // If null, we are in "New Chat" mode (not saved to DB yet)
  String _selectedPersonality = 'Friend';
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // FIX: Do NOT create a chat immediately. We wait for the first message.
    // _currentConversationId remains null.
  }

  // Used when clicking a chat from History
  void _loadConversation(String id) {
    setState(() {
      _currentConversationId = id;
    });
    Navigator.pop(context); // Closes drawer
  }

  // Used when clicking "New Chat"
  void _resetToNewChat() {
    setState(() {
      _currentConversationId = null; // Just reset UI, don't create DB entry yet
    });
    Navigator.pop(context); // Closes drawer
  }

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() => _isTyping = true);

    try {
      // FIX: Lazy Creation.
      // If we don't have an ID yet, create the DB document NOW.
      if (_currentConversationId == null) {
        final newId = await _chatService.createNewChat();
        setState(() {
          _currentConversationId = newId;
        });
      }

      // Now send the message using the valid ID
      await _chatService.sendMessage(
          _currentConversationId!,
          text,
          true,
          personality: _selectedPersonality
      );

    } catch (e) {
      // Handle error gently
      debugPrint("Error sending message: $e");
    } finally {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  void _showPersonalitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E20),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Choose AI Personality", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            _buildPersonalityTile('Friend', 'Warm, supportive, and kind.', Icons.favorite),
            _buildPersonalityTile('Coach', 'Logical, action-oriented, and stoic.', Icons.sports_score),
            _buildPersonalityTile('Zen', 'Calm, mindful, and peaceful.', Icons.self_improvement),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityTile(String name, String desc, IconData icon) {
    final isSelected = _selectedPersonality == name;
    // final theme = Theme.of(context); // (Optional: Use custom colors below)
    const kAccentColor = Color(0xFFA4A5F5);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? kAccentColor : Colors.grey[800],
        child: Icon(icon, color: isSelected ? Colors.black : Colors.grey),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? kAccentColor : Colors.white)),
      subtitle: Text(desc, style: const TextStyle(color: Colors.grey)),
      trailing: isSelected ? const Icon(Icons.check, color: kAccentColor) : null,
      onTap: () {
        setState(() => _selectedPersonality = name);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    const kChatBackground = Color(0xFF131314);
    const kSurfaceColor = Color(0xFF1E1E20);
    const kAccentColor = Color(0xFFA4A5F5);
    const kInputFillColor = Color(0xFF282828);

    return Scaffold(
      key: _scaffoldKey, // Assign the key to control drawer
      backgroundColor: kChatBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // FIX 1: Add Back Button explicit logic
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('YouMii', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          // Moved History button here since Back Button took the "Leading" spot
          IconButton(
            icon: const Icon(Icons.history, color: Colors.grey),
            tooltip: "Chat History",
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          IconButton(
            icon: const Icon(Icons.psychology, color: Colors.grey),
            tooltip: "Change Personality",
            onPressed: _showPersonalitySelector,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: kSurfaceColor,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
              child: Center(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: kAccentColor, child: Icon(Icons.person, color: Colors.white)),
                  title: Text(user?.displayName ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(user?.email ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add, color: kAccentColor),
              title: const Text("New chat", style: TextStyle(color: kAccentColor, fontWeight: FontWeight.bold)),
              onTap: _resetToNewChat, // Updated to use the non-saving method
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatService.getConversations(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No history yet", style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'New Chat';
                      final id = doc.id;
                      final isActive = id == _currentConversationId;

                      return ListTile(
                        leading: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                        title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.grey[400], fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        tileColor: isActive ? kAccentColor.withOpacity(0.1) : null,
                        onTap: () => _loadConversation(id),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                          onPressed: () {
                            _chatService.deleteConversation(id);
                            if (isActive) _resetToNewChat();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            // FIX 2: Check for NULL ID. If null, show empty state immediately (don't load stream)
            child: _currentConversationId == null
                ? _buildEmptyState(user?.displayName ?? 'Friend')
                : StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(_currentConversationId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                // Double check: if messages are empty even with an ID, show mascot
                if (messages.isEmpty) return _buildEmptyState(user?.displayName ?? 'Friend');

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => _ChatBubble(message: messages[index]),
                );
              },
            ),
          ),

          if (_isTyping)
            const Padding(padding: EdgeInsets.only(left: 20, bottom: 10), child: Align(alignment: Alignment.centerLeft, child: Text("YouMii is thinking...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12)))),

          Container(
            padding: const EdgeInsets.all(16),
            color: kChatBackground,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: kInputFillColor, borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Message YouMii...',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: kInputFillColor,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.send_rounded, color: kAccentColor), onPressed: _handleSend),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text("YouMii is an AI companion, not a medical professional.", style: TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String name) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 120, width: 120, child: Image.asset('assets/mascot.png', fit: BoxFit.contain)),
            const SizedBox(height: 20),
            Text("Hello, $name", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFA4A5F5))),
            const SizedBox(height: 8),
            const Text("How can I help you today?", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2F2F2F) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Row(children: [CircleAvatar(radius: 12, backgroundImage: AssetImage('assets/mascot.png'), backgroundColor: Colors.transparent), SizedBox(width: 8), Text("YouMii", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12))]),
              const SizedBox(height: 4),
            ],
            Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}