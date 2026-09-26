import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../screens/newsfeed_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/custom_font.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Friends / Marketplace / Menu removed
  final List<Widget> _screens = [
    const NewsFeedScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  void _onTappedBar(int value) {
    setState(() => _selectedIndex = value);
    _pageController.jumpToPage(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FB_COLOR_BLACK,
        elevation: 2,
        title: CustomFont(
          text: 'PostIt',
          fontSize: ScreenUtil().setSp(25),
          color: FB_PRIMARY,
          fontFamily: 'Klavika',
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (page) => setState(() => _selectedIndex = page),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: FB_PRIMARY,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onTappedBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}