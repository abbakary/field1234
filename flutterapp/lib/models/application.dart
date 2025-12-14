enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  withdrawn,
  completed
}

class Application {
  final String id;
  final String studentId;
  final String organizationId;
  final String studentName;
  final String organizationName;
  final ApplicationStatus status;
  final String? matchScore;
  final String? matchType;
  final DateTime appliedAt;
  final DateTime? respondedAt;
  final String? rejectionReason;
  final String? acceptanceLetter;
  final DateTime? startDate;
  final DateTime? endDate;

  Application({
    required this.id,
    required this.studentId,
    required this.organizationId,
    required this.studentName,
    required this.organizationName,
    required this.status,
    this.matchScore,
    this.matchType,
    required this.appliedAt,
    this.respondedAt,
    this.rejectionReason,
    this.acceptanceLetter,
    this.startDate,
    this.endDate,
  });

  String get statusText {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
      case ApplicationStatus.completed:
        return 'Completed';
    }
  }

  Color get statusColor {
    switch (status) {
      case ApplicationStatus.pending:
        return const Color(0xFFF59E0B);
      case ApplicationStatus.accepted:
        return const Color(0xFF10B981);
      case ApplicationStatus.rejected:
        return const Color(0xFFEF4444);
      case ApplicationStatus.withdrawn:
        return const Color(0xFF64748B);
      case ApplicationStatus.completed:
        return const Color(0xFF2563EB);
    }
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      studentName: json['student_name'] ?? '',
      organizationName: json['organization_name'] ?? '',
      status: _parseStatus(json['status'] ?? 'pending'),
      matchScore: json['match_score']?.toString(),
      matchType: json['match_type'],
      appliedAt: DateTime.parse(json['applied_at'] ?? DateTime.now().toIso8601String()),
      respondedAt: json['responded_at'] != null ? DateTime.parse(json['responded_at']) : null,
      rejectionReason: json['rejection_reason'],
      acceptanceLetter: json['acceptance_letter'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }

  static ApplicationStatus _parseStatus(String status) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase(),
      orElse: () => ApplicationStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'organization_id': organizationId,
      'student_name': studentName,
      'organization_name': organizationName,
      'status': status.name,
      'match_score': matchScore,
      'match_type': matchType,
      'applied_at': appliedAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'acceptance_letter': acceptanceLetter,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}

import 'package:flutter/material.dart';
