import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();

  String? _currentUserId;
  String _searchText = '';
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text.trim().toLowerCase());
    });
  }

  Future<void> _loadCurrentUser() async {
    final userData = await userService.value.getUserData();
    final uid = (userData?['uid'] ?? '').toString();
    if (!mounted) return;
    setState(() {
      _currentUserId =
          uid.isEmpty ? FirebaseAuth.instance.currentUser?.uid : uid;
      _isLoadingUser = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- Search Bar ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),

                // --- User List ---
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _chatService.getUsersStream(),
                    builder: (context, usersSnap) {
                      if (usersSnap.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (usersSnap.hasError) {
                        return Center(
                          child: Text(
                            'Error loading users: ${usersSnap.error}',
                          ),
                        );
                      }

                      final allUsers = usersSnap.data ?? [];

                      // Filter by search text
                      final filteredUsers = allUsers.where((user) {
                        if (_searchText.isEmpty) return true;
                        final name =
                            (user['firstName'] ?? '').toString().toLowerCase();
                        final lastName =
                            (user['lastName'] ?? '').toString().toLowerCase();
                        final email =
                            (user['email'] ?? '').toString().toLowerCase();
                        return name.contains(_searchText) ||
                            lastName.contains(_searchText) ||
                            email.contains(_searchText);
                      }).toList();

                      if (filteredUsers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchText.isEmpty
                                    ? 'No other users found'
                                    : 'No users match "$_searchText"',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        );
                      }

                      // Sort by last message time
                      return FutureBuilder<Map<String, Timestamp>>(
                        future: _chatService
                            .getLastMessageTimes(_currentUserId ?? ''),
                        builder: (context, sortSnap) {
                          final lastTimes =
                              sortSnap.data ?? <String, Timestamp>{};

                          filteredUsers.sort((a, b) {
                            final aUid = (a['uid'] ?? '').toString();
                            final bUid = (b['uid'] ?? '').toString();
                            final aTime = lastTimes[aUid];
                            final bTime = lastTimes[bUid];

                            if (aTime == null && bTime == null) {
                              final aName = (a['firstName'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              final bName = (b['firstName'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              return aName.compareTo(bName);
                            }
                            if (aTime == null) return 1;
                            if (bTime == null) return -1;
                            return bTime.compareTo(aTime);
                          });

                          return ListView.separated(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: filteredUsers.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, indent: 72),
                            itemBuilder: (context, index) {
                              return _ChatTileWithPreview(
                                user: filteredUsers[index],
                                currentUserId: _currentUserId ?? '',
                                onTap: (user) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatDetailScreen(
                                        currentUserEmail:
                                            _currentUserId ?? '',
                                        tappedUser: user,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// --- Chat Tile with Last Message + Unread Badge ---
class _ChatTileWithPreview extends StatelessWidget {
  final Map<String, dynamic> user;
  final String currentUserId;
  final void Function(Map<String, dynamic> user) onTap;

  const _ChatTileWithPreview({
    required this.user,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final userId = (user['uid'] ?? '').toString();
    final firstName = (user['firstName'] ?? '').toString();
    final lastName = (user['lastName'] ?? '').toString();
    final email = (user['email'] ?? 'No email').toString();
    final fullName = '$firstName $lastName'.trim();
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

    if (userId.isEmpty || currentUserId.isEmpty) {
      return _buildTile(
        context,
        fullName: fullName.isEmpty ? 'Unknown User' : fullName,
        email: email,
        initial: initial,
        lastMessage: '',
        lastMessageTime: null,
        unreadCount: 0,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: ChatService().getMessage(currentUserId, userId),
      builder: (context, snapshot) {
        String lastMessage = '';
        Timestamp? lastMessageTime;
        int unreadCount = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;

          final latestData = docs.first.data() as Map<String, dynamic>;
          lastMessage = (latestData['message'] ?? '').toString();
          lastMessageTime = latestData['timestamp'] as Timestamp?;

          // Count unread: incoming messages until we hit our own last reply
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final senderId = (data['senderId'] ?? '').toString();
            if (senderId != currentUserId) {
              unreadCount++;
            } else {
              break;
            }
          }
        }

        return _buildTile(
          context,
          fullName: fullName.isEmpty ? 'Unknown User' : fullName,
          email: email,
          initial: initial,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
          unreadCount: unreadCount,
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String fullName,
    required String email,
    required String initial,
    required String lastMessage,
    required Timestamp? lastMessageTime,
    required int unreadCount,
  }) {
    final hasUnread = unreadCount > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: hasUnread
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: hasUnread
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              fullName,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessageTime != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                _formatTileTime(lastMessageTime),
                style: TextStyle(
                  fontSize: 11,
                  color: hasUnread
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade600,
                  fontWeight:
                      hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                lastMessage.isEmpty ? email : lastMessage,
                style: TextStyle(
                  color:
                      hasUnread ? Colors.black87 : Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight:
                      hasUnread ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasUnread)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(minWidth: 22),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      onTap: () => onTap(user),
    );
  }

  String _formatTileTime(Timestamp ts) {
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}