// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youmii/firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home/home_screen.dart';

// Define our custom calming lavender color
const MaterialColor lavender = MaterialColor(
  0xFF8A64E5,
  <int, Color>{
    50: Color(0xFFF0EBFD),
    100: Color(0xFFDCD2F9),
    200: Color(0xFFC7B8F6),
    300: Color(0xFFB19EF3),
    400: Color(0xFF9E89F0),
    500: Color(0xFF8A64E5),
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

      // --- THIS IS THE CRITICAL CHANGE FOR TESTING ---
      // The app will now start directly on the home screen.
      home: const HomeScreen(),
      // home: const AuthGate(), // We keep this line commented out during testing.
      // --- END OF CHANGE ---

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// The AuthGate is still here, ready for when you want to re-enable it.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}