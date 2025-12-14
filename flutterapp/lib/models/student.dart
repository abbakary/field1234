class Student {
  final String id;
  final String fullName;
  final String registrationNumber;
  final String institution;
  final String level;
  final String course;
  final String department;
  final List<String> skills;
  final String preferredLocation;
  final String email;
  final String phone;
  final String? profilePhotoUrl;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.fullName,
    required this.registrationNumber,
    required this.institution,
    required this.level,
    required this.course,
    required this.department,
    required this.skills,
    required this.preferredLocation,
    required this.email,
    required this.phone,
    this.profilePhotoUrl,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      institution: json['institution'] ?? '',
      level: json['level'] ?? '',
      course: json['course'] ?? '',
      department: json['department'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      preferredLocation: json['preferred_location'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePhotoUrl: json['profile_photo_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'registration_number': registrationNumber,
      'institution': institution,
      'level': level,
      'course': course,
      'department': department,
      'skills': skills,
      'preferred_location': preferredLocation,
      'email': email,
      'phone': phone,
      'profile_photo_url': profilePhotoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
