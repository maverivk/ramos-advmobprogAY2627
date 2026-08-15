import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Settings',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            CustomText(
              text: 'Appearance',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 12.h),
            
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  // Dark Mode Switch
                  ListTile(
                    leading: Icon(
                      themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: CustomText(
                      text: themeProvider.isDark ? 'Dark Mode' : 'Light Mode',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    trailing: Switch(
                      value: themeProvider.isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  
                  Divider(
                    height: 1.h,
                    indent: 16.w,
                    endIndent: 16.w,
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
                  
                  // Theme Preview
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.color_lens,
                          size: 20.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          themeProvider.isDark ? 'Dark Theme Active' : 'Light Theme Active',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Other Settings Section
            CustomText(
              text: 'General',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 12.h),
            
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: CustomText(
                      text: 'Notifications',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  Divider(
                    height: 1.h,
                    indent: 16.w,
                    endIndent: 16.w,
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: CustomText(
                      text: 'Language',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    trailing: Text(
                      'English',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.h,
                    indent: 16.w,
                    endIndent: 16.w,
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: CustomText(
                      text: 'Version',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}