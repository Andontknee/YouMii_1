// lib/screens/home/chatbot_screen.dart

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

  // IMPORTANT: Replace this with your actual API key
  static const String _apiKey = "YOUR_API_KEY_HERE";

  // Using the confirmed model name
  final GenerativeModel _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey
  );

  // Define the YouMii persona and safety rules
  final systemInstruction = Content.text(
      """Your name is YouMii. You are a supportive and empathetic AI assistant for mental wellness.
    
    Your goals:
    - Provide a safe, non-judgmental space.
    - Suggest light stress-relieving activities (e.g., breathing exercises, walks, simple yoga).
    - Share positive wellness quotes.
    - Maintain a calm, gentle, and positive tone.

    Strict rules:
    1. NEVER provide medical advice, diagnoses, or treatment.
    2. In your FIRST response of a conversation, YOU MUST include this exact disclaimer: "Please remember, I am an AI assistant and not a substitute for professional medical advice. If you are in crisis, please contact a local emergency service or a mental health professional."
    3. If a user seems in crisis, gently repeat the disclaimer.
    4. You are an AI; do not claim to have personal feelings or a body.
    5. Keep responses concise and easy to read on a phone screen."""
  );

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;

    // Use a temporary list to manage the UI update for a smooth transition
    final tempMessages = List<Map<String, String>>.from(_messages);

    setState(() {
      tempMessages.add({'sender': 'user', 'text': userMessage});
      _messages.clear();
      _messages.addAll(tempMessages);
      _isLoading = true;
    });

    _controller.clear();

    try {
      final content = [
        systemInstruction,
        Content.text(userMessage)
      ];

      var response = await _model.generateContent(content);

      if (!mounted) return;
      setState(() {
        _messages.add({'sender': 'bot', 'text': response.text ?? "Sorry, I couldn't respond."});
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'Oops! Something went wrong. Please try again.'});
      });
      print("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- NEW WIDGET: Welcome View (Adapted to Dark Theme) ---
  Widget _buildWelcomeView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Removed the CircleAvatar with the menu button
            const SizedBox(height: 100),
            Text(
              'Welcome to YouMii',
              style: theme.textTheme.headlineMedium!.copyWith(
                color: theme.primaryColor, // Use the lavender accent color
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your personal space for mindfulness and well-being.',
              style: theme.textTheme.titleMedium!.copyWith(
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15), // Use a warning color for the safety text
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.4)),
              ),
              child: Text(
                'YouMii is an AI assistant for wellness, not a medical professional. For any crisis, please contact emergency services.',
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: Colors.red[300],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputColor = const Color(0xFF282828); // Dark grey for the input box

    return Scaffold(
      // --- FIX: Using Theme Colors ---
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('YouMii Assistant'),
        // No need for explicit colors, the global theme handles the AppBar
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeView(context)
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isUserMessage = message['sender'] == 'user';
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUserMessage ? theme.primaryColor : theme.cardColor, // Use theme colors
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isUserMessage ? const Radius.circular(20) : Radius.zero,
                        bottomRight: isUserMessage ? Radius.zero : const Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      message['text']!,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: isUserMessage ? Colors.white : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: LinearProgressIndicator()),
            ),
          // --- THE REDESIGNED INPUT BAR ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            color: theme.scaffoldBackgroundColor, // Ensure bar is flush with background
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(color: Colors.white), // White text for typing
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: inputColor, // The dark grey color for the input field
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    enabled: !_isLoading,
                    onSubmitted: (_) => _isLoading ? null : _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor: theme.primaryColor, // Use the lavender primary color
                  elevation: 0,
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}