// lib/screens/home/profile_screen.dart

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Consistent light theme background
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // For the back arrow
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        children: [
          const SizedBox(height: 20),

          // --- Profile Avatar with Upload Button ---
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 60,
                  // Placeholder image. We'll replace this with the user's uploaded image.
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.white),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () {
                        // TODO: Implement image picker functionality
                        // This will open the user's gallery or camera.
                        print('Change profile picture tapped');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- User Name and Email ---
          const Center(
            child: Text(
              'Anthony LCM', // Placeholder for user's name
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              'anthony.lcm@email.com', // Placeholder for user's email
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // --- Menu List ---
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              // TODO: Navigate to Settings Screen
            },
          ),
          ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // TODO: Navigate to Notifications Screen
            },
          ),
          ProfileMenuItem(
            icon: Icons.history_outlined,
            title: 'History',
            onTap: () {
              // TODO: Navigate to History Screen
            },
          ),
          ProfileMenuItem(
            icon: Icons.support_agent_outlined,
            title: 'Support and Help',
            onTap: () {
              // TODO: Navigate to Support Screen
            },
          ),
          const Divider(height: 40),
          ProfileMenuItem(
            icon: Icons.logout_outlined,
            title: 'Logout',
            textColor: Colors.red, // Make logout text red
            onTap: () {
              // TODO: Implement logout functionality
              // This will clear user session and navigate to login screen.
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}

// A reusable widget for the menu items to keep the code clean.
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}