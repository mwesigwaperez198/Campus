class EventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String venue;
  final String? imageUrl;
  final String? category;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    required this.venue,
    this.imageUrl,
    this.category,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventDate: DateTime.parse(json['event_date']),
      venue: json['venue'] ?? 'Campus',
      imageUrl: json['image_url'],
      category: json['category'],
    );
  }
}
