import 'package:flutter/material.dart';

enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  withdrawn,
  completed
}

class ApplicationStatusHistory {
  final int id;
  final String oldStatus;
  final String newStatus;
  final String? notes;
  final DateTime changedAt;

  ApplicationStatusHistory({
    required this.id,
    required this.oldStatus,
    required this.newStatus,
    this.notes,
    required this.changedAt,
  });

  factory ApplicationStatusHistory.fromJson(Map<String, dynamic> json) {
    return ApplicationStatusHistory(
      id: json['id'] ?? 0,
      oldStatus: json['old_status'] ?? '',
      newStatus: json['new_status'] ?? '',
      notes: json['notes'],
      changedAt: json['changed_at'] != null
          ? DateTime.parse(json['changed_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'old_status': oldStatus,
      'new_status': newStatus,
      'notes': notes,
      'changed_at': changedAt.toIso8601String(),
    };
  }
}

class TrainingOpportunity {
  final int id;
  final int organization;
  final String organizationName;
  final String title;
  final int totalSlots;
  final int remainingSlots;
  final int slotsFilled;
  final int trainingDurationMonths;
  final DateTime deadline;
  final bool isOpen;
  final DateTime postedAt;

  TrainingOpportunity({
    required this.id,
    required this.organization,
    required this.organizationName,
    required this.title,
    required this.totalSlots,
    required this.remainingSlots,
    required this.slotsFilled,
    required this.trainingDurationMonths,
    required this.deadline,
    required this.isOpen,
    required this.postedAt,
  });

  factory TrainingOpportunity.fromJson(Map<String, dynamic> json) {
    return TrainingOpportunity(
      id: json['id'] ?? 0,
      organization: json['organization'] ?? 0,
      organizationName: json['organization_name'] ?? '',
      title: json['title'] ?? '',
      totalSlots: json['total_slots'] ?? 0,
      remainingSlots: json['remaining_slots'] ?? 0,
      slotsFilled: json['slots_filled'] ?? 0,
      trainingDurationMonths: json['training_duration_months'] ?? 0,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'].toString())
          : DateTime.now(),
      isOpen: json['is_open'] ?? false,
      postedAt: json['posted_at'] != null
          ? DateTime.parse(json['posted_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization': organization,
      'organization_name': organizationName,
      'title': title,
      'total_slots': totalSlots,
      'remaining_slots': remainingSlots,
      'slots_filled': slotsFilled,
      'training_duration_months': trainingDurationMonths,
      'deadline': deadline.toIso8601String(),
      'is_open': isOpen,
      'posted_at': postedAt.toIso8601String(),
    };
  }
}

class Application {
  final int id;
  final int student;
  final Map<String, dynamic>? studentDetail;
  final int organization;
  final Map<String, dynamic>? organizationDetail;
  final int trainingOpportunity;
  final Map<String, dynamic>? opportunityDetail;
  final int matchScore;
  final String matchQuality;
  final Map<String, dynamic> matchDetails;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? respondedAt;
  final String? acceptanceLetter;
  final String? rejectionReason;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<ApplicationStatusHistory> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Application({
    required this.id,
    required this.student,
    this.studentDetail,
    required this.organization,
    this.organizationDetail,
    required this.trainingOpportunity,
    this.opportunityDetail,
    required this.matchScore,
    required this.matchQuality,
    required this.matchDetails,
    required this.status,
    required this.appliedAt,
    this.respondedAt,
    this.acceptanceLetter,
    this.rejectionReason,
    this.startDate,
    this.endDate,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
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
    List<ApplicationStatusHistory> parseStatusHistory(dynamic historyData) {
      if (historyData == null) return [];
      if (historyData is List) {
        return historyData.map((history) {
          if (history is Map<String, dynamic>) {
            return ApplicationStatusHistory.fromJson(history);
          }
          return ApplicationStatusHistory(
            id: 0,
            oldStatus: '',
            newStatus: '',
            changedAt: DateTime.now(),
          );
        }).toList();
      }
      return [];
    }

    return Application(
      id: json['id'] ?? 0,
      student: json['student'] ?? 0,
      studentDetail: json['student_detail'] is Map ? json['student_detail'] : null,
      organization: json['organization'] ?? 0,
      organizationDetail: json['organization_detail'] is Map ? json['organization_detail'] : null,
      trainingOpportunity: json['training_opportunity'] ?? 0,
      opportunityDetail: json['opportunity_detail'] is Map ? json['opportunity_detail'] : null,
      matchScore: json['match_score'] ?? 0,
      matchQuality: json['match_quality'] ?? 'not_eligible',
      matchDetails: json['match_details'] is Map ? json['match_details'] : {},
      status: _parseStatus(json['status'] ?? 'pending'),
      appliedAt: json['applied_at'] != null
          ? DateTime.parse(json['applied_at'].toString())
          : DateTime.now(),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'].toString())
          : null,
      acceptanceLetter: json['acceptance_letter'],
      rejectionReason: json['rejection_reason'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'].toString()) : null,
      statusHistory: parseStatusHistory(json['status_history']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
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
      'student': student,
      'student_detail': studentDetail,
      'organization': organization,
      'organization_detail': organizationDetail,
      'training_opportunity': trainingOpportunity,
      'opportunity_detail': opportunityDetail,
      'match_score': matchScore,
      'match_quality': matchQuality,
      'match_details': matchDetails,
      'status': status.name,
      'applied_at': appliedAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'acceptance_letter': acceptanceLetter,
      'rejection_reason': rejectionReason,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status_history': statusHistory.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
