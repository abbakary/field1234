class Skill {
  final int id;
  final String name;
  final String category;
  final String description;

  Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
    };
  }
}

class Student {
  final int id;
  final int user;
  final String username;
  final String fullName;
  final String email;
  final String registrationNumber;
  final int? institution;
  final String? institutionName;
  final int? department;
  final String? departmentName;
  final int? course;
  final String? courseName;
  final String academicLevel;
  final String phone;
  final String? profilePhoto;
  final String bio;
  final String preferredLocation;
  final List<Skill> skills;
  final bool isActive;
  final bool isPlaced;
  final DateTime? placementDate;
  final DateTime registeredAt;
  final DateTime updatedAt;

  String get level => academicLevel;

  Student({
    required this.id,
    required this.user,
    required this.username,
    required this.fullName,
    required this.email,
    required this.registrationNumber,
    this.institution,
    this.institutionName,
    this.department,
    this.departmentName,
    this.course,
    this.courseName,
    required this.academicLevel,
    required this.phone,
    this.profilePhoto,
    required this.bio,
    required this.preferredLocation,
    required this.skills,
    required this.isActive,
    required this.isPlaced,
    this.placementDate,
    required this.registeredAt,
    required this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    List<Skill> parseSkills(dynamic skillsData) {
      if (skillsData == null) return [];
      if (skillsData is List) {
        return skillsData.map((skill) {
          if (skill is Map<String, dynamic>) {
            return Skill.fromJson(skill);
          }
          return Skill(id: 0, name: skill.toString(), category: '', description: '');
        }).toList();
      }
      return [];
    }

    return Student(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      institution: json['institution'],
      institutionName: json['institution_name'],
      department: json['department'],
      departmentName: json['department_name'],
      course: json['course'],
      courseName: json['course_name'],
      academicLevel: json['academic_level'] ?? '',
      phone: json['phone'] ?? '',
      profilePhoto: json['profile_photo'],
      bio: json['bio'] ?? '',
      preferredLocation: json['preferred_location'] ?? '',
      skills: parseSkills(json['skills']),
      isActive: json['is_active'] ?? true,
      isPlaced: json['is_placed'] ?? false,
      placementDate: json['placement_date'] != null
          ? DateTime.parse(json['placement_date'].toString())
          : null,
      registeredAt: json['registered_at'] != null
          ? DateTime.parse(json['registered_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'username': username,
      'full_name': fullName,
      'email': email,
      'registration_number': registrationNumber,
      'institution': institution,
      'institution_name': institutionName,
      'department': department,
      'department_name': departmentName,
      'course': course,
      'course_name': courseName,
      'academic_level': academicLevel,
      'phone': phone,
      'profile_photo': profilePhoto,
      'bio': bio,
      'preferred_location': preferredLocation,
      'skills': skills.map((s) => s.toJson()).toList(),
      'is_active': isActive,
      'is_placed': isPlaced,
      'placement_date': placementDate?.toIso8601String(),
      'registered_at': registeredAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
