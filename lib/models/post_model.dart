class PostModel {
  final String id;
  final String userId;
  final String? caption;
  final String? imageUrl;
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatar;
  final String type;

  PostModel({
    required this.id,
    required this.userId,
    this.caption,
    this.imageUrl,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
    this.type = 'standard',
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['author_id'] ?? '',
      caption: json['caption'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      authorName: json['profiles']?['full_name'],
      authorAvatar: json['profiles']?['avatar_url'],
      type: json['type'] ?? 'standard',
    );
  }
}
