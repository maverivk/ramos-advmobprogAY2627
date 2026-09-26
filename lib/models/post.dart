class Post {
  final int id;
  final String title;
  final String body;
  final int userId;
  final int likes;
  final int dislikes;
  final int views;
  final List<String> tags;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.likes,
    required this.dislikes,
    required this.views,
    required this.tags,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final reactions = json['reactions'] as Map<String, dynamic>? ?? {};
    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] ?? 0,
      likes: (reactions['likes'] as num?)?.toInt() ?? 0,
      dislikes: (reactions['dislikes'] as num?)?.toInt() ?? 0,
      views: json['views'] ?? 0,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'userId': userId,
        'reactions': {'likes': likes, 'dislikes': dislikes},
        'views': views,
        'tags': tags,
      };
}