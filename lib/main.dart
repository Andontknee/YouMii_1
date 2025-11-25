// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Needed for AuthGate
import 'package:youmii/firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home/home_screen.dart';

// --- 🎨 COLOR PALETTE DEFINITION ---

// Brand / Primary (Kept Lavender for buttons/icons, but you might want to change this to a dark green later if you keep the Olivine background)
const Color kPrimaryLavender = Color(0xFFA795C4);
const Color kDeepLavender = Color(0xFF8A75AE);

// Backgrounds
// --- CHANGED: New Olivine Background ---
const Color kPrimaryBackground = Color(0xFF98B678);
// ---------------------------------------
const Color kSecondaryBackground = Color(0xFFE5DBF2);
const Color kCardColor = Color(0xFFF8F5FC); // Keeping cards white/lilac to pop against the green

// Typography Colors
const Color kTextHeader = Color(0xFF4A3F59);
const Color kTextBody = Color(0xFF6B6280);
const Color kTextMuted = Color(0xFF9B8BB2);

// Accents
const Color kAccentSuccess = Color(0xFF93C8A2);
const Color kAccentWarning = Color(0xFFE7CBA3);
const Color kAccentError = Color(0xFFDFA8A8);

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

      // --- THEME CONFIGURATION ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // 1. Colors
        scaffoldBackgroundColor: kPrimaryBackground,
        primaryColor: kPrimaryLavender,
        cardColor: kCardColor,
        canvasColor: kPrimaryBackground,

        colorScheme: const ColorScheme.light(
          primary: kPrimaryLavender,
          secondary: kDeepLavender,
          surface: kCardColor,
          error: kAccentError,
          onPrimary: Colors.white,
          onSurface: kTextHeader,
        ),

        // 2. Typography
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: kTextHeader, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(color: kTextHeader, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: kTextHeader, fontWeight: FontWeight.w600),

          titleLarge: TextStyle(color: kTextHeader, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: kTextBody, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: kTextBody, fontWeight: FontWeight.w500),

          bodyLarge: TextStyle(color: kTextBody, fontSize: 16),
          bodyMedium: TextStyle(color: kTextBody, fontSize: 14),
          bodySmall: TextStyle(color: kTextMuted, fontSize: 12),
        ),

        // 3. Component Themes

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: kTextHeader),
          titleTextStyle: TextStyle(color: kTextHeader, fontSize: 20, fontWeight: FontWeight.w600),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: kCardColor,
          elevation: 4,
          shadowColor: const Color.fromRGBO(138, 117, 174, 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.only(bottom: 16),
        ),

        // Input Fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD7CFEA), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD7CFEA), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kPrimaryLavender, width: 1.5),
          ),
          hintStyle: const TextStyle(color: Color(0xFFB9A9D6)),
          labelStyle: const TextStyle(color: kTextMuted),
        ),

        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryLavender,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color.fromRGBO(123, 97, 158, 0.15),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kPrimaryLavender,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Bottom Navigation Bar
        bottomAppBarTheme: const BottomAppBarThemeData(
          color: kCardColor,
          elevation: 10,
          shadowColor: Color.fromRGBO(138, 117, 174, 0.1),
        ),

        // Icons
        iconTheme: const IconThemeData(color: kPrimaryLavender),
      ),

      // Auth Gatekeeper
      home: const AuthGate(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

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