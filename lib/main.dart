// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // Optional based on version
import 'package:youmii/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home/home_screen.dart';

// --- 🎨 VIBRANT LAVENDER & CORAL PALETTE ---

// Primary Brand (Lavender - slightly richer)
const Color kPrimaryLavender = Color(0xFF7E57C2);
const Color kDeepLavender = Color(0xFF512DA8);

// Secondary Brand (Coral/Peach - Adds the "Vibrancy" from your image)
const Color kAccentCoral = Color(0xFFFF8A65);
const Color kSoftPeach = Color(0xFFFFCCBC);

// Backgrounds & Surfaces
const Color kAppBackground = Color(0xFFF4F1FA); // A very subtle lavender tint
const Color kCardSurface = Color(0xFFFFFFFF);   // Pure white for pop

// Typography
const Color kTextPrimary = Color(0xFF2D2D3A); // Nearly black, softer than pure black
const Color kTextSecondary = Color(0xFF6E6E80); // Muted grey-purple

// Status
const Color kSuccess = Color(0xFF81C784);
const Color kError = Color(0xFFE57373);

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

        // 1. Global Colors
        scaffoldBackgroundColor: kAppBackground,
        primaryColor: kPrimaryLavender,
        cardColor: kCardSurface,
        canvasColor: kAppBackground,

        // Defines the main color set for widgets
        colorScheme: const ColorScheme.light(
          primary: kPrimaryLavender,
          onPrimary: Colors.white,
          secondary: kAccentCoral, // This makes Floating Action Buttons pop!
          onSecondary: Colors.white,
          surface: kCardSurface,
          onSurface: kTextPrimary,
          error: kError,
        ),

        // 2. Typography (Google Fonts style: Poppins or Nunito recommended)
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
          headlineSmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),

          titleLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: kTextSecondary, fontWeight: FontWeight.w600),

          bodyLarge: TextStyle(color: kTextPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: kTextSecondary, fontSize: 14),
          bodySmall: TextStyle(color: kTextSecondary, fontSize: 12),
        ),

        // 3. Component Themes (The "Vibrant" Look)

        // AppBar: Clean and transparent
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: kTextPrimary),
          titleTextStyle: TextStyle(color: kTextPrimary, fontSize: 22, fontWeight: FontWeight.w700),
        ),

        // Cards: High pop, rounded corners, soft shadow
        cardTheme: CardThemeData(
          color: kCardSurface,
          elevation: 0, // Flat style with border OR low elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Very rounded like the image
            side: BorderSide.none, // Cleaner look
          ),
          margin: const EdgeInsets.only(bottom: 16),
          // Adding a subtle shadow manually in widgets often looks better,
          // but global elevation 2 is good for standard material.
        ),

        // Input Fields: Friendly and rounded
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none, // Clean, no border look
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: kPrimaryLavender, width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFFB0B0C0)),
          labelStyle: const TextStyle(color: kTextSecondary),
        ),

        // Buttons: Vibrant and Pill-shaped
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryLavender,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: kPrimaryLavender.withOpacity(0.4), // Colored shadow!
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Pill shape
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kPrimaryLavender,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),

        // Floating Action Button (The "Pop")
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: kAccentCoral, // Orange/Peach button
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),

        // Bottom Navigation Bar: Clean white
        bottomAppBarTheme: const BottomAppBarThemeData(
          color: kCardSurface,
          elevation: 20,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.white,
        ),

        // Icons
        iconTheme: const IconThemeData(color: kPrimaryLavender),
      ),

       home: const AuthGate(),
     // home: const HomeScreen(),//

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
        // 1. While checking (loading state)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. If User is logged in -> Go to Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // 3. If User is NOT logged in -> Go to Login
        return const LoginScreen();
      },
    );
  }
}