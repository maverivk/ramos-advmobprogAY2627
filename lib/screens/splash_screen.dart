// packages
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// services
import '../services/user_service.dart';

// widgets
import '../widgets/custom_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Enhancement 1: UserService instance for persistent authentication check
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    // Enhancement 1: Check if user is already logged in
    _checkAuthentication();
  }

  // Enhancement 1: Persistent authentication logic
  // If user has saved token in SharedPreferences → go to home
  // If no token → go to sign in
  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final loggedIn = await _userService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      final userData = await _userService.getUserData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: userData,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/images/NU_bulldogLogo.png',
              height: 150.h,
              width: 150.w,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.shopping_bag,
                size: 100.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24.h),

            // App Name
            CustomText(
              text: 'E-Commerce App',
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: 'Your one-stop shop',
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
            SizedBox(height: 40.h),

            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}