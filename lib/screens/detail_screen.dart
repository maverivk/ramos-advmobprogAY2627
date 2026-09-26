import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';

class DetailScreen extends StatefulWidget {
  final int postId;
  final int userId;
  final String userName;
  final String postContent;
  final String date;
  final String imageUrl;
  final String profileImageUrl;
  final int initialLikes;
  final bool initiallyLiked;

  const DetailScreen({
    super.key,
    this.postId = 0,
    this.userId = 0,
    required this.userName,
    required this.postContent,
    required this.date,
    this.imageUrl = '',
    this.profileImageUrl = '',
    this.initialLikes = 0,
    this.initiallyLiked = false,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CommentService _commentService = CommentService();
  final UserService _userService = UserService();
  final TextEditingController _commentCtrl = TextEditingController();

  late int _numOfLikes;
  late bool _isLiked;
  List<Comment> _comments = [];
  bool _loadingComments = true;

  @override
  void initState() {
    super.initState();
    _numOfLikes = widget.initialLikes;
    _isLiked = widget.initiallyLiked;
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _commentService.getCommentsByPost(widget.postId);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loadingComments = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingComments = false);
    }
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _numOfLikes--;
      } else {
        _numOfLikes++;
      }
      _isLiked = !_isLiked;
    });
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    final userId = await _userService.getUserId();
    final fullName = await _userService.getFullName();

    final optimistic = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      body: text,
      postId: widget.postId,
      likes: 0,
      userId: userId,
      username: fullName,
      fullName: fullName,
    );

    setState(() => _comments.insert(0, optimistic));
    _commentCtrl.clear();

    try {
      final created = await _commentService.addComment(
        body: text,
        postId: widget.postId,
        userId: userId,
      );
      if (!mounted) return;
      setState(() {
        _comments[0] = created;
      });
    } catch (_) {
      // Keep the optimistic comment even if API fails (DummyJSON simulates)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomFont(
          text: widget.userName,
          fontSize: ScreenUtil().setSp(20),
          color: Colors.black,
        ),
      ),
      body: Container(
        color: Colors.white,
        height: ScreenUtil().screenHeight,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.imageUrl.isNotEmpty)
                Image.network(widget.imageUrl),
              SizedBox(height: ScreenUtil().setHeight(20)),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(20)),
                child: Row(
                  children: [
                    widget.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : CircleAvatar(
                            radius: ScreenUtil().setSp(25),
                            backgroundImage:
                                NetworkImage(widget.profileImageUrl),
                          ),
                    SizedBox(width: ScreenUtil().setWidth(10)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomFont(
                          text: widget.userName,
                          fontSize: ScreenUtil().setSp(20),
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        Row(
                          children: [
                            CustomFont(
                              text: widget.date,
                              fontSize: ScreenUtil().setSp(15),
                              color: Colors.grey,
                            ),
                            SizedBox(width: ScreenUtil().setWidth(3)),
                            Icon(Icons.public,
                                color: Colors.grey,
                                size: ScreenUtil().setSp(18)),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz),
                  ],
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(15)),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(20)),
                alignment: Alignment.centerLeft,
                child: CustomFont(
                  text: widget.postContent,
                  fontSize: ScreenUtil().setSp(18),
                  color: Colors.black,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(30)),
              const Divider(),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: FB_DARK_PRIMARY,
                      ),
                      label: CustomFont(
                        text: _numOfLikes == 0
                            ? 'Like'
                            : _numOfLikes.toString(),
                        fontSize: ScreenUtil().setSp(12),
                        color: FB_DARK_PRIMARY,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.comment,
                          color: FB_DARK_PRIMARY),
                      label: CustomFont(
                        text: 'Comment',
                        fontSize: ScreenUtil().setSp(12),
                        color: FB_DARK_PRIMARY,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.redo, color: FB_DARK_PRIMARY),
                      label: CustomFont(
                        text: 'Share',
                        fontSize: ScreenUtil().setSp(12),
                        color: FB_DARK_PRIMARY,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Add comment input
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(20),
                    vertical: ScreenUtil().setHeight(10)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _submitComment,
                      icon: const Icon(Icons.send,
                          color: FB_DARK_PRIMARY),
                    ),
                  ],
                ),
              ),
              // Comments list
              if (_loadingComments)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
              else if (_comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No comments yet. Be the first!'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final c = _comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: FB_LIGHT_PRIMARY,
                        child: Text(
                          c.fullName.isNotEmpty
                              ? c.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: CustomFont(
                        text: c.fullName,
                        fontSize: ScreenUtil().setSp(14),
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      subtitle: CustomFont(
                        text: c.body,
                        fontSize: ScreenUtil().setSp(13),
                        color: Colors.black87,
                      ),
                    );
                  },
                ),
              SizedBox(height: ScreenUtil().setHeight(20)),
            ],
          ),
        ),
      ),
    );
  }
}