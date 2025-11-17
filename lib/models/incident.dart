class Incident {
  final String id;
  final String type;
  final String description;
  final String location;
  final DateTime timestamp;
  final String urgency;
  final String status;
  final bool isVerified;
  final int upvotes;
  final int comments;
  final String? imageUrl;

  Incident({
    required this.id,
    required this.type,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.urgency,
    this.status = 'Active',
    this.isVerified = false,
    this.upvotes = 0,
    this.comments = 0,
    this.imageUrl,
  });

  Incident copyWith({
    String? id,
    String? type,
    String? description,
    String? location,
    DateTime? timestamp,
    String? urgency,
    String? status,
    bool? isVerified,
    int? upvotes,
    int? comments,
    String? imageUrl,
  }) {
    return Incident(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      upvotes: upvotes ?? this.upvotes,
      comments: comments ?? this.comments,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}