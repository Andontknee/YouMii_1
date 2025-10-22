import 'package:flutter/material.dart';
// import 'screens/auth/login_screen.dart';        // <-- 1. COMMENT OUT THIS LINE
// import 'screens/auth/registration_screen.dart'; // <-- 2. COMMENT OUT THIS LINE
import 'screens/home/home_screen.dart';         // <-- This one is okay because you have it

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouMii',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      
      // --- CHANGES ARE HERE ---

      // initialRoute: '/login', // <-- 3. COMMENT OUT the initial route
      
      // 4. INSTEAD, use the 'home' property to go straight to HomeScreen
      home: HomeScreen(),

      // We can leave the routes for later, or comment them out too.
      // routes: {
      //   '/login': (context) => LoginScreen(),
      //   '/register': (context) => RegistrationScreen(),
      //   '/home': (context) => HomeScreen(),
      // },
    );
  }
}