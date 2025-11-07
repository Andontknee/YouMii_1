// lib/services/quote_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // NEW IMPORT

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['q'] ?? "Be yourself; everyone else is already taken.",
      author: json['a'] ?? "Oscar Wilde",
    );
  }
}

class QuoteService {
  static const String _url = "https://zenquotes.io/api/random";
  static const String _quoteKey = "daily_quote_text";
  static const String _authorKey = "daily_quote_author";
  static const String _dateKey = "daily_quote_date";

  Future<Quote> fetchDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // Format: YYYY-MM-DD

    // 1. Check if a quote was saved today
    final savedDate = prefs.getString(_dateKey);

    if (savedDate == today) {
      // If it's the same day, return the cached quote
      final cachedQuote = prefs.getString(_quoteKey) ?? "Consistency is key.";
      final cachedAuthor = prefs.getString(_authorKey) ?? "App Developer";
      return Quote(text: cachedQuote, author: cachedAuthor);
    }

    // 2. If no quote is saved for today, fetch a new one
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          final newQuote = Quote.fromJson(data[0] as Map<String, dynamic>);

          // 3. Cache the new quote and the date
          prefs.setString(_quoteKey, newQuote.text);
          prefs.setString(_authorKey, newQuote.author);
          prefs.setString(_dateKey, today);

          return newQuote;
        }
      }

      // Fallback on API/parsing error
      throw Exception('API/Parsing error occurred.');

    } catch (e) {
      print('Quote API Error (Fallback): $e');
      // Final fallback if network fails
      return Quote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb");
    }
  }
}