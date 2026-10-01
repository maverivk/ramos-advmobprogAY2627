import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;

  const ChatDetailScreen({
    super.key,
    required this.currentUserEmail,
    required this.tappedUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _msgFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  late Future<String> _currentUserIdFuture;
  bool _isSending = false;
  Timestamp? _sendingStartedAt;

  static const _postSendDelay = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _currentUserIdFuture = _getCurrentUserId();
  }

  Future<String> _getCurrentUserId() async {
    final userData = await userService.value.getUserData();
    final uid = (userData?['uid'] ?? '').toString();
    if (uid.isEmpty) {
      final authUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      debugPrint('getUserData() returned no uid. Fallback to Auth: $authUid');
      return authUid;
    }
    return uid;
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String currentUserId, String receiverId) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _sendingStartedAt = Timestamp.now();
    });

    try {
      await ChatService().sendMessage(receiverId, text);
      _msgCtrl.clear();
      _msgFocus.requestFocus();

      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }

      await Future.delayed(_postSendDelay);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _sendingStartedAt = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tappedUserId = (widget.tappedUser['uid'] ?? '').toString();
    final tappedUserName =
        (widget.tappedUser['firstName'] ?? 'Chat').toString();
    final tappedUserInitial = tappedUserName.isNotEmpty
        ? tappedUserName[0].toUpperCase()
        : '?';

    return FutureBuilder<String>(
      future: _currentUserIdFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Error loading user data')),
          );
        }

        final currentUserId = snap.data!;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    tappedUserInitial,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  tappedUserName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      ChatService().getMessage(currentUserId, tappedUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    List<QueryDocumentSnapshot> docs =
                        snapshot.data?.docs ?? [];

                    if (_isSending && _sendingStartedAt != null) {
                      docs = docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final senderId =
                            (data['senderId'] ?? '').toString();
                        final ts = data['timestamp'];
                        if (senderId != currentUserId) return true;
                        if (ts is Timestamp) {
                          return ts.compareTo(_sendingStartedAt!) < 0;
                        }
                        return true;
                      }).toList();
                    }

                    if (docs.isEmpty && !_isSending) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      controller: _scrollCtrl,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      itemCount: docs.length + (_isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isSending && index == 0) {
                          return _buildSendingBubble();
                        }

                        final docIndex = _isSending ? index - 1 : index;
                        final data =
                            docs[docIndex].data() as Map<String, dynamic>;
                        final msgText = (data['message'] ?? '').toString();
                        final senderId =
                            (data['senderId'] ?? '').toString();
                        final isMe = senderId == currentUserId;
                        final timestamp = data['timestamp'] as Timestamp?;

                        return _AnimatedMessageBubble(
                          key: ValueKey(docs[docIndex].id),
                          message: msgText,
                          isMe: isMe,
                          timestamp: timestamp,
                        );
                      },
                    );
                  },
                ),
              ),
              _buildComposer(currentUserId, tappedUserId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Say hi to start the conversation!',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSendingBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 12,
              width: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'sending...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(String currentUserId, String tappedUserId) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                focusNode: _msgFocus,
                enabled: !_isSending,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                onSubmitted: (_) =>
                    _isSending ? null : _send(currentUserId, tappedUserId),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isSending
                    ? null
                    : () => _send(currentUserId, tappedUserId),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Animated Message Bubble ---
class _AnimatedMessageBubble extends StatefulWidget {
  final String message;
  final bool isMe;
  final Timestamp? timestamp;

  const _AnimatedMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
  });

  @override
  State<_AnimatedMessageBubble> createState() =>
      _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<_AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.isMe ? 0.3 : -0.3, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = widget.isMe;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              top: 3,
              bottom: 6,
              left: isMe ? 60 : 8,
              right: isMe ? 8 : 60,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isMe
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isMe
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(widget.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe
                            ? theme.colorScheme.onPrimary.withOpacity(0.7)
                            : Colors.grey.shade600,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color:
                            theme.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}