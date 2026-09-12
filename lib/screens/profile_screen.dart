// packages
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// services
import '../services/user_service.dart';

// widgets
import '../widgets/custom_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Enhancement 3: Load user data from SharedPreferences using UserService
  final UserService _userService = UserService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Enhancement 3: Fetch saved user data from SharedPreferences
  Future<void> _loadUserData() async {
    final data = await _userService.getUserData();
    if (!mounted) return;
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  // Enhancement 3: Logout - clear user data and navigate to splash screen
  Future<void> _logout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(
          text: 'Logout',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        content: CustomText(
          text: 'Are you sure you want to log out?',
          fontSize: 13.sp,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: CustomText(text: 'Cancel', fontSize: 13.sp),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: CustomText(
              text: 'Logout',
              fontSize: 13.sp,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _userService.logout();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/splash');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userData == null) {
      return Center(
        child: CustomText(
          text: 'No user data found',
          fontSize: 14.sp,
        ),
      );
    }

    final user = _userData!;
    final String fullName =
        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
    final String username = user['username'] ?? 'Unknown';
    final String email = user['email'] ?? '';
    final String gender = user['gender'] ?? '';
    final String image = user['image'] ?? '';
    final int userId = user['id'] ?? 0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          SizedBox(height: 8.h),

          // Profile Avatar
          CircleAvatar(
            radius: 50.r,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
            child: image.isEmpty
                ? Icon(
                    Icons.person,
                    size: 50.sp,
                    color: Theme.of(context).primaryColor,
                  )
                : null,
          ),
          SizedBox(height: 12.h),

          // Full Name
          CustomText(
            text: fullName.isNotEmpty ? fullName : username,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),

          // Username
          CustomText(
            text: '@$username',
            fontSize: 13.sp,
            color: Theme.of(context).hintColor,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),

          // User Info Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Account Information',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 12.h),

                _buildInfoRow(context, Icons.badge_outlined, 'User ID', userId.toString()),
                _buildDivider(context),
                _buildInfoRow(context, Icons.person_outline, 'Username', username),
                _buildDivider(context),
                _buildInfoRow(context, Icons.email_outlined, 'Email', email.isNotEmpty ? email : 'N/A'),
                _buildDivider(context),
                _buildInfoRow(context, Icons.wc_outlined, 'Gender', gender.isNotEmpty ? gender : 'N/A'),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout, size: 18.sp, color: Colors.white),
              label: CustomText(
                text: 'Logout',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
          SizedBox(width: 12.w),
          CustomText(
            text: label,
            fontSize: 13.sp,
            color: Theme.of(context).hintColor,
          ),
          const Spacer(),
          Flexible(
            child: CustomText(
              text: value,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1.h,
      color: Theme.of(context).dividerColor.withOpacity(0.15),
    );
  }
}