import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';
import '../widgets/newsfeed_card.dart';
import 'detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final PostService _postService = PostService();

  User? _user;
  List<Post> _myPosts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = await _userService.getUserId();
      if (userId == 0) {
        setState(() {
          _error = 'No user session';
          _loading = false;
        });
        return;
      }
      final user = await _userService.getUserById(userId);
      final posts = await _postService.getPostsByUser(userId);
      if (!mounted) return;
      setState(() {
        _user = user;
        _myPosts = posts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings').then((_) => _loadProfile());
  }

  void _openDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          postId: post.id,
          userId: post.userId,
          userName: _user!.fullName,
          postContent: post.body,
          date: post.tags.isNotEmpty ? '#${post.tags.first}' : '',
          profileImageUrl: _user!.image,
          initialLikes: post.likes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _openSettings,
            ),
          ],
        ),
        body: Center(child: Text(_error ?? 'No user data')),
      );
    }

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Smaller cover photo area
                    Container(
                      height: 140,
                      decoration: BoxDecoration(color: Colors.grey[300]),
                    ),
                    Positioned(
                      bottom: -40,
                      left: ScreenUtil().setWidth(20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: _user!.image.isNotEmpty
                                ? NetworkImage(_user!.image)
                                : null,
                            child: _user!.image.isEmpty
                                ? Text(_user!.initials)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.settings,
                            color: Colors.black87),
                        onPressed: _openSettings,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setHeight(45)),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: _user!.fullName,
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(20),
                        color: Colors.black,
                      ),
                      SizedBox(height: ScreenUtil().setHeight(5)),
                      CustomFont(
                        text: _user!.email,
                        fontSize: ScreenUtil().setSp(13),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(15)),
                TabBar(
                  indicatorColor: FB_DARK_PRIMARY,
                  tabs: [
                    Tab(
                      child: CustomFont(
                        text: 'Posts',
                        fontSize: ScreenUtil().setSp(15),
                        color: Colors.black,
                      ),
                    ),
                    Tab(
                      child: CustomFont(
                        text: 'About',
                        fontSize: ScreenUtil().setSp(15),
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(600),
                  child: TabBarView(
                    children: [
                      _myPosts.isEmpty
                          ? const Center(child: Text('No posts yet'))
                          : ListView.builder(
                              itemCount: _myPosts.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final post = _myPosts[index];
                                return NewsfeedCard(
                                  postId: post.id,
                                  userId: post.userId,
                                  userName: _user!.fullName,
                                  userAvatar: _user!.initials,
                                  postContent: post.body,
                                  postDate: post.tags.isNotEmpty
                                      ? '#${post.tags.first}'
                                      : '',
                                  hasImage: false,
                                  likeCount: post.likes,
                                  commentCount: 0,
                                  isInitiallyLiked: false,
                                  profileImageUrl: _user!.image,
                                  onCommentTap: () => _openDetail(post),
                                );
                              },
                            ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(20),
                          vertical: ScreenUtil().setHeight(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomFont(
                              text: 'Personal Details',
                              fontSize: ScreenUtil().setSp(18),
                              fontWeight: FontWeight.bold,
                              color: FB_DARK_PRIMARY,
                            ),
                            SizedBox(height: ScreenUtil().setHeight(15)),
                            CustomFont(
                              text: 'Username:',
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(15),
                              color: Colors.black,
                            ),
                            CustomFont(
                              text: _user!.username,
                              fontSize: ScreenUtil().setSp(14),
                              color: Colors.grey.shade700,
                            ),
                            SizedBox(height: ScreenUtil().setHeight(12)),
                            CustomFont(
                              text: 'Email:',
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(15),
                              color: Colors.black,
                            ),
                            CustomFont(
                              text: _user!.email,
                              fontSize: ScreenUtil().setSp(14),
                              color: Colors.grey.shade700,
                            ),
                            SizedBox(height: ScreenUtil().setHeight(12)),
                            CustomFont(
                              text: 'Gender:',
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(15),
                              color: Colors.black,
                            ),
                            CustomFont(
                              text: _user!.gender,
                              fontSize: ScreenUtil().setSp(14),
                              color: Colors.grey.shade700,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}