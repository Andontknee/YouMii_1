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

  String? _currentConversationId;
  String _selectedPersonality = 'Friend';
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    final newId = await _chatService.createNewChat();
    if (mounted) {
      setState(() {
        _currentConversationId = newId;
      });
    }
  }

  void _loadConversation(String id) {
    setState(() {
      _currentConversationId = id;
    });
    Navigator.pop(context);
  }

  void _createNewChat() async {
    final newId = await _chatService.createNewChat();
    setState(() {
      _currentConversationId = newId;
    });
    Navigator.pop(context);
  }

  void _handleSend() async {
    if (_controller.text.trim().isEmpty || _currentConversationId == null) return;

    final text = _controller.text.trim();
    _controller.clear();
    setState(() => _isTyping = true);

    await _chatService.sendMessage(_currentConversationId!, text, true, personality: _selectedPersonality);

    if (mounted) setState(() => _isTyping = false);
  }

  void _showPersonalitySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Choose AI Personality", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? theme.primaryColor : Colors.grey[200],
        child: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? theme.primaryColor : Colors.black)),
      subtitle: Text(desc),
      trailing: isSelected ? Icon(Icons.check, color: theme.primaryColor) : null,
      onTap: () {
        setState(() => _selectedPersonality = name);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // --- COLORS ---
    const kChatBackground = Color(0xFF131314); // Gemini Dark
    const kSurfaceColor = Color(0xFF1E1E20);
    const kAccentColor = Color(0xFFA4A5F5); // Periwinkle
    const kInputFillColor = Color(0xFF282828); // Dark Grey for Input Box

    return Scaffold(
      backgroundColor: kChatBackground,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
        title: const Text('YouMii', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
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
              onTap: _createNewChat,
            ),
            const Divider(color: Colors.white10),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
              child: Align(alignment: Alignment.centerLeft, child: Text("Recent", style: TextStyle(color: Colors.grey, fontSize: 12))),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatService.getConversations(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;

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
                            if (isActive) _initializeChat();
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
          // --- CHAT AREA ---
          Expanded(
            child: _currentConversationId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(_currentConversationId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return _buildEmptyState(user?.displayName ?? 'Friend');
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _ChatBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),

          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              child: Align(alignment: Alignment.centerLeft, child: Text("YouMii is thinking...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12))),
            ),

          // --- INPUT AREA ---
          Container(
            padding: const EdgeInsets.all(16),
            color: kChatBackground,
            child: Column(
              children: [
                // Container for the Capsule Shape
                Container(
                  decoration: BoxDecoration(
                    color: kInputFillColor, // #282828
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(color: Colors.white), // White text
                          decoration: const InputDecoration(
                            hintText: 'Message YouMii...',
                            hintStyle: TextStyle(color: Colors.grey),
                            // --- FIX: Explicitly set fillColor here to override Global White ---
                            filled: true,
                            fillColor: kInputFillColor,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                          ),
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: kAccentColor),
                        onPressed: _handleSend,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "YouMii may display inaccurate info. Not a medical professional. Seek help if in crisis.",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String name) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mascot Image
          SizedBox(
            height: 120,
            width: 120,
            child: Image.asset('assets/mascot.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: 20),
          Text("Hello, $name", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFA4A5F5))),
          const SizedBox(height: 8),
          const Text("How can I help you today?", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
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
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage('assets/mascot.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(width: 8),
                  const Text("YouMii", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.text,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}