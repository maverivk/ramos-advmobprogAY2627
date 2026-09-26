import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/comment.dart';

class CommentService {
  // Enhancement 3: Get all comments for a given post
  Future<List<Comment>> getCommentsByPost(int postId) async {
    final url = Uri.parse('$host/comments/post/$postId');
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List commentsJson = data['comments'] ?? [];
      return commentsJson.map((c) => Comment.fromJson(c)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}');
    }
  }

  // Enhancement 3: Add a new comment (simulated by DummyJSON)
  Future<Comment> addComment({
    required String body,
    required int postId,
    required int userId,
  }) async {
    final url = Uri.parse('$host/comments/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'body': body,
        'postId': postId,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add comment: ${response.statusCode}');
    }
  }
}