// lib/screens/home/profile_screen.dart

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- USING THEME VARIABLES ---
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.iconTheme,
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
                  // Placeholder image
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: theme.scaffoldBackgroundColor),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () {
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
          Center(
            child: Text(
              'Anthony LCM', // Placeholder for user's name
              style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              'anthony.lcm@email.com', // Placeholder for user's email
              style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey[500]),
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
          const Divider(height: 40, color: Colors.grey),
          ProfileMenuItem(
            icon: Icons.logout_outlined,
            title: 'Logout',
            textColor: Colors.redAccent, // Make logout text red
            onTap: () {
              // TODO: Implement logout functionality
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
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor, // Use cardColor for the menu item background
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Colors.grey[600]),
        title: Text(
          title,
          style: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.white, // Ensure text is white
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
        onTap: onTap,
      ),
    );
  }
}