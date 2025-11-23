// lib/screens/home/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import to show real user data if needed

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    // Use real user data if available, otherwise fallback
    final String displayName = user?.displayName ?? 'Anthony LCM';
    final String email = user?.email ?? 'anthony.lcm@email.com';
    final String photoUrl = user?.photoURL ?? 'https://i.pravatar.cc/150?img=3';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'), // Theme handles the color now
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        children: [
          const SizedBox(height: 20),

          // --- Profile Avatar with Upload Button ---
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(photoUrl),
                  backgroundColor: theme.primaryColor.withOpacity(0.2),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      // This border matches the background color to create a "cutout" effect
                      border: Border.all(width: 3, color: theme.scaffoldBackgroundColor),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () {
                        // TODO: Implement image picker logic
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit Profile Picture')));
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
              displayName,
              style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              email,
              style: theme.textTheme.bodyMedium!.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
            ),
          ),
          const SizedBox(height: 40),

          // --- Menu List ---
          // No longer passing specific colors so it uses the Theme defaults
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {},
          ),
          ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          ProfileMenuItem(
            icon: Icons.history_outlined,
            title: 'History',
            onTap: () {},
          ),
          ProfileMenuItem(
            icon: Icons.support_agent_outlined,
            title: 'Support and Help',
            onTap: () {},
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1),
          ),

          ProfileMenuItem(
            icon: Icons.logout_outlined,
            title: 'Logout',
            textColor: theme.colorScheme.error, // Use the error color from theme (Red)
            iconColor: theme.colorScheme.error,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

// A reusable widget for the menu items
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // The card color is now automatically White based on main.dart theme
      elevation: 0, // Flat style for a cleaner look on the light background
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? theme.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? theme.primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor ?? theme.textTheme.titleMedium?.color, // FIX: Inherits dark text now
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}