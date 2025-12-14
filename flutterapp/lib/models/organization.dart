class Organization {
  final String id;
  final String name;
  final String industryType;
  final String location;
  final String description;
  final List<String> supportedCourses;
  final List<String> supportedLevels;
  final List<String> requiredSkills;
  final int totalSlots;
  final int remainingSlots;
  final String trainingDuration;
  final String? logoUrl;
  final String? website;
  final String? email;
  final String? phone;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  Organization({
    required this.id,
    required this.name,
    required this.industryType,
    required this.location,
    required this.description,
    required this.supportedCourses,
    required this.supportedLevels,
    required this.requiredSkills,
    required this.totalSlots,
    required this.remainingSlots,
    required this.trainingDuration,
    this.logoUrl,
    this.website,
    this.email,
    this.phone,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
  });

  bool get isSlotsAvailable => remainingSlots > 0;

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      industryType: json['industry_type'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      supportedCourses: List<String>.from(json['supported_courses'] ?? []),
      supportedLevels: List<String>.from(json['supported_levels'] ?? []),
      requiredSkills: List<String>.from(json['required_skills'] ?? []),
      totalSlots: json['total_slots'] ?? 0,
      remainingSlots: json['remaining_slots'] ?? 0,
      trainingDuration: json['training_duration'] ?? '',
      logoUrl: json['logo_url'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'industry_type': industryType,
      'location': location,
      'description': description,
      'supported_courses': supportedCourses,
      'supported_levels': supportedLevels,
      'required_skills': requiredSkills,
      'total_slots': totalSlots,
      'remaining_slots': remainingSlots,
      'training_duration': trainingDuration,
      'logo_url': logoUrl,
      'website': website,
      'email': email,
      'phone': phone,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
