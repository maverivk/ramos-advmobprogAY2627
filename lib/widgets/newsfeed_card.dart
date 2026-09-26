import 'package:flutter/material.dart';
import 'custom_font.dart';
import 'post_action_button.dart';

class NewsfeedCard extends StatefulWidget {
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
  final VoidCallback? onCommentTap;

  const NewsfeedCard({
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
    this.onCommentTap,
  });

  @override
  State<NewsfeedCard> createState() => _NewsfeedCardState();
}

class _NewsfeedCardState extends State<NewsfeedCard> {
  late bool _isLiked;
  late int _currentLikeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isInitiallyLiked;
    _currentLikeCount = widget.likeCount;
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _currentLikeCount++;
      } else {
        _currentLikeCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const defaultPlaceholder = 'https://via.placeholder.com/400x200';

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[100],
                    image: widget.profileImageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.profileImageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.profileImageUrl.isEmpty
                      ? Center(
                          child: Text(
                            widget.userAvatar,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: widget.userName,
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      CustomFont(
                        text: widget.postDate,
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomFont(
              text: widget.postContent,
              fontSize: 14,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            if (widget.hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.imageUrl.isNotEmpty
                      ? widget.imageUrl
                      : defaultPlaceholder,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image,
                        size: 50, color: Colors.grey),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                          child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                PostActionButton(
                  icon: Icons.thumb_up_outlined,
                  activeIcon: Icons.thumb_up,
                  label: 'Like',
                  count: _currentLikeCount,
                  initialState: _isLiked,
                  onPressed: _handleLike,
                ),
                // Comment button: NO counter, just opens the detail screen
                GestureDetector(
                  onTap: widget.onCommentTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.comment_outlined,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Comment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}