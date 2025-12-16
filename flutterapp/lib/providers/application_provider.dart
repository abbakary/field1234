import 'package:flutter/foundation.dart';
import '../models/application.dart';
import '../services/api_service.dart';

class ApplicationProvider extends ChangeNotifier {
  List<Application> _applications = [];
  Application? _selectedApplication;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;

  List<Application> get applications => _applications;
  Application? get selectedApplication => _selectedApplication;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  int get pendingApplications =>
      _applications.where((app) => app.status == ApplicationStatus.pending).length;
  int get acceptedApplications =>
      _applications.where((app) => app.status == ApplicationStatus.accepted).length;
  int get rejectedApplications =>
      _applications.where((app) => app.status == ApplicationStatus.rejected).length;
  int get completedApplications =>
      _applications.where((app) => app.status == ApplicationStatus.completed).length;

  Future<void> fetchApplications({
    int? student,
    int? organization,
    String? status,
    String? search,
    int page = 1,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.getApplications(
        student: student,
        organization: organization,
        status: status,
        search: search,
        page: page,
      );

      if (result['success']) {
        final data = result['data'];

        // Handle different API response formats
        if (data is Map<String, dynamic>) {
          // Check for paginated response
          if (data.containsKey('results')) {
            // Standard DRF pagination response
            final results = data['results'] as List;
            _applications = results.map((app) {
              return Application.fromJson(app as Map<String, dynamic>);
            }).toList();

            // Extract pagination info
            _currentPage = page;
            _totalPages = ((data['count'] ?? 0) as int) ~/ 20 + 1;
          } else {
            _applications = [];
          }
        } else if (data is List) {
          // Direct list response
          _applications = (data as List).map((app) {
            return Application.fromJson(app as Map<String, dynamic>);
          }).toList();
        } else {
          _applications = [];
        }

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to fetch applications';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyToOpportunity({
    required int trainingOpportunityId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.submitApplication(
        trainingOpportunityId: trainingOpportunityId,
      );

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        final newApplication = Application.fromJson(data);
        _applications.insert(0, newApplication);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to submit application';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getApplicationDetail(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.getApplication(id);

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        _selectedApplication = Application.fromJson(data);

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to fetch application';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> withdrawApplication(int applicationId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.withdrawApplication(
        applicationId: applicationId,
      );

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        final updatedApplication = Application.fromJson(data);
        
        final index = _applications.indexWhere((app) => app.id == applicationId);
        if (index != -1) {
          _applications[index] = updatedApplication;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to withdraw application';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptApplication({
    required int applicationId,
    String? acceptanceLetter,
    String? startDate,
    String? endDate,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.acceptApplication(
        applicationId: applicationId,
        acceptanceLetter: acceptanceLetter,
        startDate: startDate,
        endDate: endDate,
      );

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        final updatedApplication = Application.fromJson(data);
        
        final index = _applications.indexWhere((app) => app.id == applicationId);
        if (index != -1) {
          _applications[index] = updatedApplication;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to accept application';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectApplication({
    required int applicationId,
    String? reason,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.rejectApplication(
        applicationId: applicationId,
        reason: reason,
      );

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        final updatedApplication = Application.fromJson(data);
        
        final index = _applications.indexWhere((app) => app.id == applicationId);
        if (index != -1) {
          _applications[index] = updatedApplication;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to reject application';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    _applications = [];
    _selectedApplication = null;
    _errorMessage = null;
    _currentPage = 1;
    _totalPages = 1;
    notifyListeners();
  }
}
