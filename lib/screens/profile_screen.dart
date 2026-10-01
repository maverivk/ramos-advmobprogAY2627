import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await userService.value.getUserData();
    if (!mounted) return;
    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    await userService.value.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final loginType = userService.value.loginType;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Avatar ---
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(
                  loginType == LoginType.firebase
                      ? Icons.local_fire_department
                      : Icons.cloud,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Login Type Label ---
            Center(
              child: Text(
                loginType == LoginType.firebase
                    ? 'Firebase User'
                    : 'DummyJSON User',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- User Data Card ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userData != null) ...[
                      _infoRow(
                        'Name',
                        '${userData!['firstName'] ?? ''} ${userData!['lastName'] ?? ''}',
                      ),
                      _infoRow('Username', '${userData!['username'] ?? 'N/A'}'),
                      _infoRow('Email', '${userData!['email'] ?? 'N/A'}'),
                      _infoRow('Age', '${userData!['age'] ?? 'N/A'}'),
                      _infoRow(
                        'Contact',
                        '${userData!['contactNo'] ?? userData!['phone'] ?? 'N/A'}',
                      ),
                    ] else
                      const Text('No user data available.'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Settings ---
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Update Username'),
              onTap: _showUpdateUsernameDialog,
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: _showChangePasswordDialog,
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _showDeleteAccountDialog,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // --- Update Username Dialog ---
  void _showUpdateUsernameDialog() {
    final controller =
        TextEditingController(text: userData?['username'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await userService.value
                    .updateUsername(username: controller.text.trim());
                if (!mounted) return;
                Navigator.pop(ctx);
                await _loadUserData();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Username updated!')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // --- Change Password Dialog ---
  void _showChangePasswordDialog() {
    final currentPass = TextEditingController();
    final newPass = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await userService.value.resetPasswordFromCurrentPassword(
                  currentPassword: currentPass.text.trim(),
                  newPassword: newPass.text.trim(),
                  email: userData?['email'] ?? '',
                );
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed!')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // --- Delete Account Dialog ---
  void _showDeleteAccountDialog() {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will permanently delete your account. Enter your password to confirm.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await userService.value.deleteAccount(
                  email: userData?['email'] ?? '',
                  password: passController.text.trim(),
                );
                if (!mounted) return;
                Navigator.pop(ctx);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}