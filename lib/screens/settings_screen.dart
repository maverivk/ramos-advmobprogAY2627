import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userService.logout();
      if (!mounted) return;
      // Route through splash so user sees the transition
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/splash',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FB_COLOR_BLACK,
        title: CustomFont(
          text: 'Settings',
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.red),
            title: CustomFont(
              text: 'Sign Out',
              fontSize: 15,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}