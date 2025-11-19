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
  
  // Real coordinates from the data
  final double? latitude;
  final double? longitude;

  Incident({
    required this.id,
    required this.type,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.urgency,
    required this.status,
    required this.isVerified,
    required this.upvotes,
    required this.comments,
    this.latitude,
    this.longitude,
  });

  // Check if incident has valid coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  // copyWith method - allows creating a copy with some fields changed
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
    double? latitude,
    double? longitude,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] ?? '',
      type: json['type'] ?? 'Other',
      description: json['description'] ?? '',
      location: json['location'] ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      urgency: json['urgency'] ?? 'Medium',
      status: json['status'] ?? 'Active',
      isVerified: json['isVerified'] ?? false,
      upvotes: json['upvotes'] ?? 0,
      comments: json['comments'] ?? 0,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'urgency': urgency,
      'status': status,
      'isVerified': isVerified,
      'upvotes': upvotes,
      'comments': comments,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}