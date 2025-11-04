// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:youmii/firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home/home_screen.dart';

// Define our custom calming lavender color
const MaterialColor lavender = MaterialColor(
  0xFF8A64E5, // Primary value
  <int, Color>{
    50: Color(0xFFF0EBFD),
    100: Color(0xFFDCD2F9),
    200: Color(0xFFC7B8F6),
    300: Color(0xFFB19EF3),
    400: Color(0xFF9E89F0),
    500: Color(0xFF8A64E5), // Base color
    600: Color(0xFF7E5BD0),
    700: Color(0xFF7052BC),
    800: Color(0xFF6248A8),
    900: Color(0xFF4B3482),
  },
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouMii',

      // --- THE NEW GLOBAL DARK THEME ---
      theme: ThemeData(
        // Colors
        primarySwatch: lavender, // Use our custom lavender color
        primaryColor: const Color(0xFF8A64E5),
        brightness: Brightness.dark, // Set the whole app to dark theme
        scaffoldBackgroundColor: const Color(0xFF121212), // Darkest background
        cardColor: const Color(0xFF1F1F1F), // Slightly lighter surface for cards
        canvasColor: const Color(0xFF1F1F1F), // For pop-ups/dialogs

        // Text/Icon Colors
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),

        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8A64E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // --- END OF THEME ---

      home: const HomeScreen(), // Start at home for easy testing

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}