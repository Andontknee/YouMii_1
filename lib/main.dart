// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:youmii/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home/home_screen.dart';

// --- 🎨 HYBRID PALETTE: COTTON CANDY + MINTY FRESH ---

// 1. Cotton Candy (Emotions, Auth, Navigation)
const Color kPrimaryLavender = Color(0xFFB298E7); // Soft Pop Purple
const Color kSoftPink = Color(0xFFF5B8D5);        // Mood/Heart

// 2. Minty Fresh (Actions, Growth, Success)
const Color kFreshMint = Color(0xFF98FBCB);       // Vibrant Mint
const Color kSageGreen = Color(0xFF7FCFA8);       // Balanced Green

// 3. Neutrals
const Color kAppBackground = Color(0xFFF9FAFC);   // Clean Cloud White
const Color kCardSurface = Color(0xFFFFFFFF);     // Pure White
const Color kTextPrimary = Color(0xFF2D2D3A);     // Soft Black
const Color kTextSecondary = Color(0xFF888899);   // Muted Grey

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
        useMaterial3: true,
        brightness: Brightness.light,

        // Global Colors
        scaffoldBackgroundColor: kAppBackground,
        primaryColor: kPrimaryLavender,
        cardColor: kCardSurface,

        // Define both palettes in the ColorScheme
        colorScheme: const ColorScheme.light(
          primary: kPrimaryLavender,    // Cotton Candy
          secondary: kSageGreen,        // Minty Fresh (Used for accents/floating buttons)
          tertiary: kSoftPink,          // Extra Cotton Candy accent
          surface: kCardSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: kTextPrimary,
        ),

        // Typography
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
          headlineSmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: kTextPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: kTextSecondary, fontSize: 14),
        ),

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: kTextPrimary),
          titleTextStyle: TextStyle(color: kTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        ),

        // Cards: Clean White with Soft Shadow
        cardTheme: CardThemeData(
          color: kCardSurface,
          elevation: 0, // Flat look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFF0F0F5), width: 1), // Subtle border
          ),
          margin: const EdgeInsets.only(bottom: 16),
        ),

        // Buttons (Lavender - Cotton Candy Style)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryLavender,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),

        // Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFEEEEF2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: kPrimaryLavender, width: 2)),
        ),

        // Bottom Nav
        bottomAppBarTheme: const BottomAppBarThemeData(
          color: Colors.white,
          elevation: 10,
          surfaceTintColor: Colors.white,
        ),

        // Icons
        iconTheme: const IconThemeData(color: kPrimaryLavender),
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