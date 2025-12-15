class Institution {
  final int id;
  final String name;
  final String institutionType;
  final String location;
  final String description;
  final String? phone;
  final String? email;
  final String? website;
  final bool isActive;
  final int departmentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Institution({
    required this.id,
    required this.name,
    required this.institutionType,
    required this.location,
    required this.description,
    this.phone,
    this.email,
    this.website,
    required this.isActive,
    required this.departmentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      institutionType: json['institution_type'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      isActive: json['is_active'] ?? true,
      departmentCount: json['department_count'] ?? 0,
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
      'name': name,
      'institution_type': institutionType,
      'location': location,
      'description': description,
      'phone': phone,
      'email': email,
      'website': website,
      'is_active': isActive,
      'department_count': departmentCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Department {
  final int id;
  final int institution;
  final String institutionName;
  final String name;
  final String description;
  final String? headOfDepartment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Department({
    required this.id,
    required this.institution,
    required this.institutionName,
    required this.name,
    required this.description,
    this.headOfDepartment,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? 0,
      institution: json['institution'] ?? 0,
      institutionName: json['institution_name'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      headOfDepartment: json['head_of_department'],
      isActive: json['is_active'] ?? true,
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
      'institution': institution,
      'institution_name': institutionName,
      'name': name,
      'description': description,
      'head_of_department': headOfDepartment,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
