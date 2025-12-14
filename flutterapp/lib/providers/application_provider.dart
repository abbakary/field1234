import 'package:flutter/foundation.dart';
import '../models/application.dart';

class ApplicationProvider extends ChangeNotifier {
  List<Application> _applications = [];
  Application? _selectedApplication;
  bool _isLoading = false;
  String? _errorMessage;

  List<Application> get applications => _applications;
  Application? get selectedApplication => _selectedApplication;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingApplications =>
      _applications.where((app) => app.status == ApplicationStatus.pending).length;
  int get acceptedApplications =>
      _applications.where((app) => app.status == ApplicationStatus.accepted).length;
  int get rejectedApplications =>
      _applications.where((app) => app.status == ApplicationStatus.rejected).length;

  Future<void> fetchApplications(String studentId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1500));

      _applications = _generateMockApplications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyToOrganization({
    required String studentId,
    required String organizationId,
    required String organizationName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1200));

      final newApplication = Application(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        organizationId: organizationId,
        studentName: 'John Doe',
        organizationName: organizationName,
        status: ApplicationStatus.pending,
        matchScore: '85',
        matchType: 'Highly Matched',
        appliedAt: DateTime.now(),
      );

      _applications.insert(0, newApplication);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getApplicationDetail(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 800));

      _selectedApplication =
          _applications.firstWhere((app) => app.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> withdrawApplication(String applicationId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1000));

      final index = _applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        _applications[index] = Application(
          id: _applications[index].id,
          studentId: _applications[index].studentId,
          organizationId: _applications[index].organizationId,
          studentName: _applications[index].studentName,
          organizationName: _applications[index].organizationName,
          status: ApplicationStatus.withdrawn,
          matchScore: _applications[index].matchScore,
          matchType: _applications[index].matchType,
          appliedAt: _applications[index].appliedAt,
          respondedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<Application> _generateMockApplications() {
    return [
      Application(
        id: '1',
        studentId: '1',
        organizationId: '1',
        studentName: 'John Doe',
        organizationName: 'TechCorp Tanzania',
        status: ApplicationStatus.accepted,
        matchScore: '92',
        matchType: 'Highly Matched',
        appliedAt: DateTime.now().subtract(const Duration(days: 5)),
        respondedAt: DateTime.now().subtract(const Duration(days: 2)),
        acceptanceLetter: 'Dear John, We are pleased to offer you...',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 120)),
      ),
      Application(
        id: '2',
        studentId: '1',
        organizationId: '2',
        studentName: 'John Doe',
        organizationName: 'Construction & Engineering Ltd',
        status: ApplicationStatus.pending,
        matchScore: '78',
        matchType: 'Partially Matched',
        appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Application(
        id: '3',
        studentId: '1',
        organizationId: '3',
        studentName: 'John Doe',
        organizationName: 'Finance Solutions Africa',
        status: ApplicationStatus.rejected,
        matchScore: '55',
        matchType: 'Not Eligible',
        appliedAt: DateTime.now().subtract(const Duration(days: 10)),
        respondedAt: DateTime.now().subtract(const Duration(days: 8)),
        rejectionReason: 'Your skills do not match our current requirements.',
      ),
    ];
  }
}
