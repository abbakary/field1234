import 'student.dart';

class Course {
  final int id;
  final String name;
  final String code;
  final int department;
  final String departmentName;
  final String level;
  final String description;
  final int durationMonths;
  final bool isActive;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.department,
    required this.departmentName,
    required this.level,
    required this.description,
    required this.durationMonths,
    required this.isActive,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      department: json['department'] ?? 0,
      departmentName: json['department_name'] ?? '',
      level: json['level'] ?? '',
      description: json['description'] ?? '',
      durationMonths: json['duration_months'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'department': department,
      'department_name': departmentName,
      'level': level,
      'description': description,
      'duration_months': durationMonths,
      'is_active': isActive,
    };
  }
}

class Organization {
  final int id;
  final int user;
  final String username;
  final String name;
  final String industryType;
  final String location;
  final String description;
  final String phone;
  final String email;
  final String? website;
  final String? logo;
  final String contactPerson;
  final List<Course> supportedCourses;
  final List<Skill> requiredSkills;
  final bool isVerified;
  final DateTime? verifiedAt;
  final bool isActive;
  final double rating;
  final int reviewCount;
  final int totalSlots;
  final int remainingSlots;
  final String trainingDuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organization({
    required this.id,
    required this.user,
    required this.username,
    required this.name,
    required this.industryType,
    required this.location,
    required this.description,
    required this.phone,
    required this.email,
    this.website,
    this.logo,
    required this.contactPerson,
    required this.supportedCourses,
    required this.requiredSkills,
    required this.isVerified,
    this.verifiedAt,
    required this.isActive,
    required this.rating,
    required this.reviewCount,
    required this.totalSlots,
    required this.remainingSlots,
    required this.trainingDuration,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSlotsAvailable => remainingSlots > 0;

  factory Organization.fromJson(Map<String, dynamic> json) {
    List<Course> parseCourses(dynamic coursesData) {
      if (coursesData == null) return [];
      if (coursesData is List) {
        return coursesData.map((course) {
          if (course is Map<String, dynamic>) {
            return Course.fromJson(course);
          }
          return Course(
            id: 0,
            name: course.toString(),
            code: '',
            department: 0,
            departmentName: '',
            level: '',
            description: '',
            durationMonths: 0,
            isActive: true,
          );
        }).toList();
      }
      return [];
    }

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

    return Organization(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      industryType: json['industry_type'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'],
      logo: json['logo'],
      contactPerson: json['contact_person'] ?? '',
      supportedCourses: parseCourses(json['supported_courses']),
      requiredSkills: parseSkills(json['required_skills']),
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'].toString())
          : null,
      isActive: json['is_active'] ?? true,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      totalSlots: json['total_slots'] ?? 0,
      remainingSlots: json['remaining_slots'] ?? 0,
      trainingDuration: json['training_duration'] ?? '0 months',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
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
      'name': name,
      'industry_type': industryType,
      'location': location,
      'description': description,
      'phone': phone,
      'email': email,
      'website': website,
      'logo': logo,
      'contact_person': contactPerson,
      'supported_courses': supportedCourses.map((c) => c.toJson()).toList(),
      'required_skills': requiredSkills.map((s) => s.toJson()).toList(),
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
      'is_active': isActive,
      'rating': rating,
      'review_count': reviewCount,
      'total_slots': totalSlots,
      'remaining_slots': remainingSlots,
      'training_duration': trainingDuration,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
