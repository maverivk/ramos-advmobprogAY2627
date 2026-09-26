import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';
import 'newsfeed_card.dart';

class PostCard extends StatefulWidget {
  final int postId;
  final int userId;
  final String userName;
  final String userAvatar;
  final String postContent;
  final String postDate;
  final bool hasImage;
  final int likeCount;
  final int commentCount;
  final bool isInitiallyLiked;
  final String imageUrl;
  final String profileImageUrl;

  const PostCard({
    super.key,
    this.postId = 0,
    this.userId = 0,
    required this.userName,
    required this.userAvatar,
    required this.postContent,
    required this.postDate,
    this.hasImage = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isInitiallyLiked = false,
    this.imageUrl = '',
    this.profileImageUrl = '',
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int _currentLikes;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _currentLikes = widget.likeCount;
    _isLiked = widget.isInitiallyLiked;
  }

  Future<void> _openDetailScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          postId: widget.postId,
          userId: widget.userId,
          userName: widget.userName,
          postContent: widget.postContent,
          date: widget.postDate,
          imageUrl: widget.hasImage
              ? (widget.imageUrl.isNotEmpty
                  ? widget.imageUrl
                  : 'https://via.placeholder.com/400x200')
              : '',
          profileImageUrl: widget.profileImageUrl,
          initialLikes: _currentLikes,
          initiallyLiked: _isLiked,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openDetailScreen,
      child: NewsfeedCard(
        postId: widget.postId,
        userId: widget.userId,
        userName: widget.userName,
        userAvatar: widget.userAvatar,
        postContent: widget.postContent,
        postDate: widget.postDate,
        hasImage: widget.hasImage,
        likeCount: _currentLikes,
        commentCount: widget.commentCount,
        isInitiallyLiked: _isLiked,
        imageUrl: widget.hasImage
            ? (widget.imageUrl.isNotEmpty
                ? widget.imageUrl
                : 'https://via.placeholder.com/400x200')
            : '',
        profileImageUrl: widget.profileImageUrl,
      ),
    );
  }
}