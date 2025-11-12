
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  static const String _apiKey = "AIzaSyA9TbKqGXyNdnFqovfE7Lj3y-qpYcMlI6g"; // Use your key

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash', // The confirmed model name
    apiKey: _apiKey
  );

  // --- NEW ---
  // We now have two versions of the system instructions.
  
  // 1. The full instruction with the mandatory disclaimer rule.
  final _fullSystemInstruction = Content.text(
    """Your name is YouMii, a supportive AI assistant for mental wellness. Your goals are to provide a safe space, suggest light stress-relieving activities, and share positive quotes. You must follow these strict rules: 1. **NEVER provide medical advice.** 2. **You MUST include this exact disclaimer in your response:** "Please remember, I am an AI assistant and not a substitute for professional medical advice. If you are in crisis, please contact a local emergency service or a mental health professional." 3. You are an AI; do not claim feelings. 4. Keep responses concise."""
  );

  // 2. A simpler instruction without the mandatory disclaimer rule for general conversation.
  final _simpleSystemInstruction = Content.text(
    """Your name is YouMii, a supportive AI assistant for mental wellness. Your goals are to provide a safe space, suggest light stress-relieving activities, and share positive quotes. You must follow these strict rules: 1. **NEVER provide medical advice.** 2. You are an AI; do not claim feelings. 3. Keep responses concise."""
  );

  // --- HEAVILY MODIFIED sendMessage FUNCTION ---
  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;

    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
      _isLoading = true;
    });

    _controller.clear();

    try {
      // Step 1: Moderation Check
      // We ask the model a simple question to classify the user's intent.
      final moderationPrompt = [
        Content.text("Is the following user message about a serious mental health crisis, self-harm, or a request for medical diagnosis? Answer only with 'YES' or 'NO'. User message: '$userMessage'")
      ];
      final moderationResponse = await _model.generateContent(moderationPrompt);
      final isCritical = moderationResponse.text?.trim().toUpperCase() == 'YES';
      
      // Step 2: Choose the right system instruction
      final instruction = isCritical ? _fullSystemInstruction : _simpleSystemInstruction;

      // Step 3: Generate the actual response
      final content = [
        instruction,
        Content.text(userMessage)
      ];

      final response = await _model.generateContent(content);
      
      setState(() {
        _messages.add({'sender': 'bot', 'text': response.text ?? "Sorry, I couldn't respond."});
      });

    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'Oops! Something went wrong. Please try again.'});
      });
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouMii Assistant'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // --- MODIFIED --- We check if the messages list is empty to show the welcome screen.
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const WelcomeView() // Show welcome screen if no messages
                : _buildChatList(),   // Show chat list if there are messages
          ),
          if (_isLoading)
             const Padding(
               padding: EdgeInsets.all(8.0),
               child: Center(child: LinearProgressIndicator()),
             ),
          _buildInputArea(), // The text input field at the bottom
        ],
      ),
    );
  }

  // --- NEW WIDGET --- For the chat list
  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[_messages.length - 1 - index];
        final isUserMessage = message['sender'] == 'user';
        return Align(
          alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUserMessage ? Colors.teal : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUserMessage ? const Radius.circular(20) : Radius.zero,
                bottomRight: isUserMessage ? Radius.zero : const Radius.circular(20),
              ),
            ),
            child: Text(
              message['text']!,
              style: TextStyle(
                color: isUserMessage ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  // --- NEW WIDGET --- For the text input area
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              enabled: !_isLoading,
              onSubmitted: (_) => _isLoading ? null : _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: Colors.teal,
            elevation: 0,
            mini: true,
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// --- NEW WIDGET --- This is the welcome screen inspired by Copilot
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Welcome to YouMii',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your personal space for mindfulness and well-being.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.withOpacity(0.2)),
            ),
            child: Text(
              'YouMii is an AI assistant for wellness, not a medical professional. For any crisis, please contact emergency services.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.teal[800],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

