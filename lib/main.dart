import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/home_screen.dart';
import 'screens/newsfeed_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';

void main() => runApp(const FacebookReplication());

class FacebookReplication extends StatelessWidget {
  const FacebookReplication({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Post It',
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/signin': (context) => const SignInScreen(),
            '/home': (context) => const HomeScreen(),
            '/newsfeed': (context) => const NewsFeedScreen(),
            '/notifications': (context) => const NotificationScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}