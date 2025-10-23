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

  // A variable to show a loading indicator while we wait for the API response.
  bool _isLoading = false;

  // IMPORTANT: Replace this with your actual API key from Google AI Studio
  static const String _apiKey = "AIzaSyA9TbKqGXyNdnFqovfE7Lj3y-qpYcMlI6g";

  // Initialize the Generative AI Model

  final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

  // The _sendMessage function is now an "async" function to handle the API call
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;

      // Add the user's message to the UI
      setState(() {
        _messages.add({'sender': 'user', 'text': userMessage});
        _isLoading = true; // Show the loading indicator
      });

      _controller.clear(); // Clear the input field

      try {
        // Send the message to the Gemini API
        final content = [Content.text(userMessage)];
        final response = await model.generateContent(content);
        
        // Add the bot's response to the UI
        setState(() {
          _messages.add({'sender': 'bot', 'text': response.text ?? "Sorry, I couldn't respond."});
        });

      } catch (e) {
        // Handle any errors that might occur during the API call
        setState(() {
          _messages.add({'sender': 'bot', 'text': 'Oops! Something went wrong. Please try again.'});
        });
        // You can also print the error to the console for debugging
        print("Error: $e");
      } finally {
        // Hide the loading indicator once we have a response or an error
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouMii Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['sender'] == 'user';
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.teal[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(message['text']!),
                  ),
                );
              },
            ),
          ),

          // A widget to show the loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    // Don't allow typing while the bot is thinking
                    enabled: !_isLoading, 
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  // Disable the send button while waiting for a response
                  onPressed: _isLoading ? null : _sendMessage, 
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}