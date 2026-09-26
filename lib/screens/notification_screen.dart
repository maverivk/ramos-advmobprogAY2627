import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../widgets/notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      'name': 'John Doe',
      'post': 'New Photo Album',
      'description': 'John uploaded new photos to "Summer Vacation 2023"',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'name': 'Jane Smith',
      'post': 'Ako moscov user',
      'description': 'Jane commented on your post: "Great photo!"',
      'time': '5 hours ago',
      'isRead': true,
    },
    {
      'name': 'Mike Johnson',
      'post': 'Event Invitation',
      'description': 'Mike invited you to "Birthday Party at 8PM"',
      'time': '1 day ago',
      'isRead': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: FB_COLOR_BLACK,
        elevation: 2,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: FB_COLOR_BLACK.withOpacity(0.1),
        ),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItem(
            name: notification['name'] as String,
            post: notification['post'] as String,
            description: notification['description'] as String,
            time: notification['time'] as String,
            isRead: notification['isRead'] as bool,
          );
        },
      ),
    );
  }
}