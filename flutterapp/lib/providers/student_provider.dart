import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/institution.dart';
import '../models/organization.dart';
import '../services/api_service.dart';

class StudentProvider extends ChangeNotifier {
  Student? _currentStudent;
  List<Institution> _institutions = [];
  List<Skill> _availableSkills = [];
  bool _isLoading = false;
  String? _errorMessage;

  Student? get currentStudent => _currentStudent;
  List<Institution> get institutions => _institutions;
  List<Skill> get availableSkills => _availableSkills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.getMyProfile();

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        _currentStudent = Student.fromJson(data);

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to fetch profile';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInstitutions({
    String? search,
    int page = 1,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.getInstitutions(
        search: search,
        page: page,
      );

      if (result['success']) {
        final data = result['data'];

        // Handle different API response formats
        if (data is Map<String, dynamic>) {
          // Check for paginated response
          if (data.containsKey('results')) {
            final results = data['results'] as List;
            _institutions = results.map((inst) {
              return Institution.fromJson(inst as Map<String, dynamic>);
            }).toList();
          } else {
            _institutions = [];
          }
        } else if (data is List) {
          // Direct list response
          _institutions = (data as List).map((inst) {
            return Institution.fromJson(inst as Map<String, dynamic>);
          }).toList();
        } else {
          _institutions = [];
        }

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to fetch institutions';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableSkills({
    String? search,
    int page = 1,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.getSkills(
        search: search,
        page: page,
      );

      if (result['success']) {
        final data = result['data'];

        // Handle different API response formats
        if (data is Map<String, dynamic>) {
          // Check for paginated response
          if (data.containsKey('results')) {
            final results = data['results'] as List;
            _availableSkills = results.map((skill) {
              return Skill.fromJson(skill as Map<String, dynamic>);
            }).toList();
          } else {
            _availableSkills = [];
          }
        } else if (data is List) {
          // Direct list response
          _availableSkills = (data as List).map((skill) {
            return Skill.fromJson(skill as Map<String, dynamic>);
          }).toList();
        } else {
          _availableSkills = [];
        }

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to fetch skills';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStudentSkills(List<int> skillIds) async {
    try {
      if (_currentStudent == null) {
        _errorMessage = 'Student not loaded';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.updateStudentSkills(
        studentId: _currentStudent!.id,
        skillIds: skillIds,
      );

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        _currentStudent = Student.fromJson(data);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to update skills';
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

  Future<void> fetchStudent(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.getStudent(id);

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        _currentStudent = Student.fromJson(data);

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to fetch student';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    _currentStudent = null;
    _institutions = [];
    _availableSkills = [];
    _errorMessage = null;
    notifyListeners();
  }
}
