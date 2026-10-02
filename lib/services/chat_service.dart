import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    final currentUid = _firebaseAuth.currentUser?.uid;
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUid)
          .map((doc) {
            final data = doc.data();
            data['uid'] = data['uid'] ?? doc.id;
            return data;
          })
          .toList();
    });
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    final String currentUserId = currentUser.uid;
    final String currentUserEmail = currentUser.email ?? '';
    final Timestamp timestamp = Timestamp.now();

    final MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
      isRead: false,
    );

    final List<String> ids = [currentUserId, receiverId]..sort();
    final String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessage(String userId, String otherUserId) {
    final List<String> ids = [userId, otherUserId]..sort();
    final String chatRoomId = ids.join('_');
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Mark incoming messages as read (with readAt timestamp)
  Future<void> markMessagesAsRead(
      String currentUserId, String otherUserId) async {
    final List<String> ids = [currentUserId, otherUserId]..sort();
    final String chatRoomId = ids.join('_');

    final unreadSnap = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    if (unreadSnap.docs.isEmpty) return;

    final now = Timestamp.now();
    final batch = _firestore.batch();
    for (final doc in unreadSnap.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': now,
      });
    }
    await batch.commit();
  }

  Future<Map<String, Timestamp>> getLastMessageTimes(
      String currentUserId) async {
    final result = <String, Timestamp>{};
    final chatRooms = await _firestore.collection('chat_rooms').get();

    for (final room in chatRooms.docs) {
      final ids = room.id.split('_');
      if (!ids.contains(currentUserId)) continue;

      final otherId = ids.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      if (otherId.isEmpty) continue;

      final messages = await room.reference
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messages.docs.isNotEmpty) {
        final ts = messages.docs.first.data()['timestamp'] as Timestamp?;
        if (ts != null) result[otherId] = ts;
      }
    }
    return result;
  }

  Future<String?> getUidByEmail(String email) async {
    final q = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (q.docs.isEmpty) return null;
    final data = q.docs.first.data();
    return (data['uid'] ?? q.docs.first.id).toString();
  }
}