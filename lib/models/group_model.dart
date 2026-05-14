class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String? imageUrl;
  final int memberCount;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.imageUrl,
    this.memberCount = 0,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      imageUrl: json['image_url'],
      memberCount: json['member_count'] ?? 0,
    );
  }
}
