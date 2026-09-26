// /lib/widgets/notification.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart'; // Colors etc
import 'custom_font.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.name,
    required this.post,
    required this.description,
    this.time = '2 hours ago',
    this.isRead = false,
    this.imageUrl = '', // NEW: optional image URL
  });

  final String name;
  final String post;
  final String description;
  final String time;
  final bool isRead;
  final String imageUrl; // NEW

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setSp(15)),
      color: isRead ? Colors.white : Colors.blue.shade50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar or image
          Container(
            width: ScreenUtil().setSp(50),
            height: ScreenUtil().setSp(50),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FB_LIGHT_PRIMARY,
              border: Border.all(color: FB_PRIMARY, width: 2),
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl.isEmpty
                ? Icon(
                    Icons.person,
                    size: ScreenUtil().setSp(30),
                    color: Colors.white,
                  )
                : null,
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomFont(
                        text: name,
                        fontSize: ScreenUtil().setSp(18),
                        color: FB_COLOR_BLACK,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    CustomFont(
                      text: time,
                      fontSize: ScreenUtil().setSp(12),
                      color: FB_COLOR_BLACK.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setHeight(4)),
                CustomFont(
                  text: 'Posted: $post',
                  fontSize: ScreenUtil().setSp(14),
                  color: FB_PRIMARY,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: ScreenUtil().setHeight(4)),
                CustomFont(
                  text: description,
                  fontSize: ScreenUtil().setSp(13),
                  color: FB_COLOR_BLACK,
                ),
                SizedBox(height: ScreenUtil().setHeight(8)),
                if (!isRead)
                  Container(
                    height: ScreenUtil().setHeight(8),
                    width: ScreenUtil().setWidth(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: FB_PRIMARY,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          IconButton(
            onPressed: () {
              // Handle more options
            },
            icon: Icon(
              Icons.more_horiz,
              size: ScreenUtil().setSp(24),
              color: FB_COLOR_BLACK.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
