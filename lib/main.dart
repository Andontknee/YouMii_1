// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:youmii/firebase_options.dart'; // Ensure this file exists

import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home/home_screen.dart';

// --- 🎨 VIBRANT LAVENDER & CORAL PALETTE ---

// Brand / Primary
const Color kPrimaryLavender = Color(0xFF906DD1);
const Color kDeepLavender = Color(0xFF8A75AE);

// Backgrounds
const Color kAppBackground = Color(0xFFEBF4FA);
const Color kCardSurface = Color(0xFFB099C8);

// Typography
const Color kTextPrimary = Colors.black;
const Color kTextSecondary = Colors.black87;

// Accents
const Color kAccentError = Color(0xFFDFA8A8);

// --- MAIN ENTRY POINT ---
Future<void> main() async {
  // 1. Ensure Flutter bindings are ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the secret keys from .env
  // We try to load this BEFORE Firebase or the App starts.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ CRITICAL ERROR: .env file not found or couldn't be loaded: $e");
    // If this fails, ChatService will likely crash the app later.
    // Make sure '.env' is added to your pubspec.yaml assets!
  }

  // 3. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. Run the App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouMii',
      debugShowCheckedModeBanner: false,

      // --- THEME CONFIGURATION ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // 1. Global Colors
        scaffoldBackgroundColor: kAppBackground,
        primaryColor: kPrimaryLavender,
        cardColor: kCardSurface,
        canvasColor: kAppBackground,

        colorScheme: const ColorScheme.light(
          primary: kPrimaryLavender,
          secondary: kDeepLavender,
          surface: kCardSurface,
          error: kAccentError,
          onPrimary: Colors.black,
          onSurface: kTextPrimary,
        ),

        // 2. Typography
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
          headlineSmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: kTextSecondary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: kTextPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: kTextPrimary, fontSize: 14),
          bodySmall: TextStyle(color: kTextSecondary, fontSize: 12),
        ),

        // 3. Component Themes

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: kTextPrimary),
          titleTextStyle: TextStyle(
            color: kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: kCardSurface,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.only(bottom: 16),
        ),

        // Input Fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: kDeepLavender, width: 2),
          ),
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: kTextPrimary),
        ),

        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryLavender,
            foregroundColor: Colors.black,
            elevation: 4,
            shadowColor: Colors.black26,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),

        // Bottom Navigation Bar
        bottomAppBarTheme: const BottomAppBarThemeData(
          color: Colors.white,
          elevation: 10,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.white,
        ),

        // Icons
        iconTheme: const IconThemeData(color: Colors.black),
      ),

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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}