// lib/main.dart (With Authentication Listener)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NEW IMPORT
import 'package:youmii/firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home/home_screen.dart';

// Define custom lavender color (remains the same)
const MaterialColor lavender = MaterialColor(
  0xFF8A64E5,
  <int, Color>{
    50: Color(0xFFF0EBFD), 100: Color(0xFFDCD2F9), 200: Color(0xFFC7B8F6),
    300: Color(0xFFB19EF3), 400: Color(0xFF9E89F0), 500: Color(0xFF8A64E5),
    600: Color(0xFF7E5BD0), 700: Color(0xFF7052BC), 800: Color(0xFF6248A8),
    900: Color(0xFF4B3482),
  },
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Note: We remove GoogleSignIn().initialize() if it causes errors

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouMii',

      theme: ThemeData(
        primarySwatch: lavender,
        primaryColor: const Color(0xFF8A64E5),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1F1F1F),
        canvasColor: const Color(0xFF1F1F1F),

        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),

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

      // --- CHANGE: Home is now the AuthGate ---
      home: const AuthGate(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// --- NEW WIDGET: Authentication Gatekeeper ---
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to the Firebase Auth state: is there a logged-in user (User?) or not (null)?
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading screen while connecting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the user is logged in (User != null)
        if (snapshot.hasData) {
          // The Home screen will display for them.
          return const HomeScreen();
        }

        // Otherwise (User == null)
        // The Login screen will display, protecting the app.
        return const LoginScreen();
      },
    );
  }
}