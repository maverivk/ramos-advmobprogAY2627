import 'package:flutter/material.dart';
import '../constants.dart'; // ADD THIS IMPORT

class PostActionButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int count;
  final VoidCallback onPressed;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool initialState;

  const PostActionButton({
    super.key,
    required this.icon,
    this.activeIcon,
    required this.label,
    this.count = 0,
    required this.onPressed,
    this.activeColor = FB_PRIMARY, // CHANGE THIS LINE ONLY
    this.inactiveColor,
    this.initialState = false,
  });

  @override
  State<PostActionButton> createState() => _PostActionButtonState();
}

class _PostActionButtonState extends State<PostActionButton> {
  late bool _isActive;
  late int _currentCount;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialState;
    _currentCount = widget.count;
  }

  void _handleTap() {
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _currentCount++;
      } else {
        _currentCount--;
      }
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = _isActive;
    final currentIcon = isLiked ? (widget.activeIcon ?? widget.icon) : widget.icon;
    final currentColor = isLiked ? widget.activeColor : widget.inactiveColor ?? Colors.grey[600];

    return GestureDetector(
      onTap: _handleTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(currentIcon, size: 20, color: currentColor),
            const SizedBox(width: 6),
            Text(
              _currentCount > 0 ? _currentCount.toString() : widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: currentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}