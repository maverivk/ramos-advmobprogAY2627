import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/user_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_font.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameCtrl = TextEditingController(text: 'emilys');
  final _passwordCtrl = TextEditingController(text: 'emilyspass');
  final _userService = UserService();
  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await _userService.login(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (user != null && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/splash',
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _error = 'Login failed. Check credentials.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PostIt',
                style: TextStyle(
                  color: FB_DARK_PRIMARY,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomFont(
                    text: _error!,
                    fontSize: 13,
                    color: Colors.red,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        buttonName: 'Log In',
                        fontColor: Colors.white,
                        backgroundColor: FB_DARK_PRIMARY,
                        onPressed: _handleLogin,
                      ),
              ),
              const SizedBox(height: 12),
              CustomFont(
                text: 'Demo: emilys / emilyspass',
                fontSize: 12,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}