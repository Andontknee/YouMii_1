// lib/screens/home/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localImagePath = prefs.getString('profile_pic_${user?.uid}');
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_pic_${user?.uid}', image.path);
      setState(() {
        _localImagePath = image.path;
      });
    }
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // FIX: Force White Background
          surfaceTintColor: Colors.transparent, // Remove tint
          title: const Text("Recent Mood History"),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mood_logs')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('dateLogged', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No mood logs found yet."));
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Text(data['moodEmoji'] ?? '', style: const TextStyle(fontSize: 24)),
                      title: Text(data['moodLabel'] ?? 'Unknown'),
                      subtitle: Text(data['dateLogged'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // FIX: Force White Background
          surfaceTintColor: Colors.transparent,
          title: const Text("Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                value: true,
                onChanged: (val) {},
                title: const Text("Daily Reminders"),
                activeColor: Theme.of(context).primaryColor,
              ),
              SwitchListTile(
                value: false,
                onChanged: (val) {},
                title: const Text("Sound Effects"),
                activeColor: Theme.of(context).primaryColor,
              ),
              SwitchListTile(
                value: true,
                onChanged: (val) {},
                title: const Text("Private Mode"),
                subtitle: const Text("Hide content from lock screen"),
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))
          ],
        );
      },
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // FIX: Force White Background
        surfaceTintColor: Colors.transparent,
        title: const Text("Contact Support"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Have feedback or facing issues?"),
            SizedBox(height: 10),
            Row(children: [Icon(Icons.email, size: 16), SizedBox(width: 8), Text("support@youmii.com")]),
            SizedBox(height: 5),
            Row(children: [Icon(Icons.web, size: 16), SizedBox(width: 8), Text("www.youmii.com")]),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String displayName = user?.displayName ?? 'Friend';
    final String email = user?.email ?? 'No Email';

    final ImageProvider profileImage = _localImagePath != null
        ? FileImage(File(_localImagePath!)) as ImageProvider
        : NetworkImage(user?.photoURL ?? 'https://i.pravatar.cc/150?img=3');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        children: [
          const SizedBox(height: 20),

          // --- Profile Avatar ---
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profileImage,
                  backgroundColor: theme.primaryColor.withOpacity(0.2),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(width: 3, color: theme.scaffoldBackgroundColor),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- User Info ---
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
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: _showSettingsDialog,
          ),
          // Removed Notifications Item as requested
          ProfileMenuItem(
            icon: Icons.history_outlined,
            title: 'Mood History',
            onTap: _showHistoryDialog,
          ),
          ProfileMenuItem(
            icon: Icons.support_agent_outlined,
            title: 'Support and Help',
            onTap: _showSupportDialog,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1),
          ),

          ProfileMenuItem(
            icon: Icons.logout_outlined,
            title: 'Logout',
            // FIX: Darker Red for better contrast
            textColor: Colors.red.shade700,
            iconColor: Colors.red.shade700,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}

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
      color: Colors.white, // Ensure cards are white
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            color: textColor ?? theme.textTheme.titleMedium?.color,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}