import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  Student? _currentStudent;
  String? _authToken;
  String? _errorMessage;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  Student? get currentStudent => _currentStudent;
  String? get authToken => _authToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      await ApiService.initialize();
      final token = ApiService.getAuthToken();
      if (token != null) {
        _authToken = token;
        _isAuthenticated = true;
        // Try to fetch current user profile
        await fetchUserProfile();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize authentication: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.studentLogin(
        username: username,
        password: password,
      );

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        _authToken = data['token']?.toString();
        
        // Parse student data if available
        if (data.containsKey('student') && data['student'] is Map) {
          _currentStudent = Student.fromJson(data['student'] as Map<String, dynamic>);
        }

        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error']?.toString() ?? 'Login failed';
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

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    required String firstName,
    required String lastName,
    required String registrationNumber,
    required int institution,
    required int course,
    required String academicLevel,
    required String phone,
    String? preferredLocation,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.studentRegister(
        username: username,
        email: email,
        password: password,
        password2: password2,
        firstName: firstName,
        lastName: lastName,
        registrationNumber: registrationNumber,
        institution: institution,
        course: course,
        academicLevel: academicLevel,
        phone: phone,
        preferredLocation: preferredLocation,
      );

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        _authToken = data['token']?.toString();
        
        // Parse student data if available
        if (data.containsKey('student') && data['student'] is Map) {
          _currentStudent = Student.fromJson(data['student'] as Map<String, dynamic>);
        }

        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error']?.toString() ?? 'Registration failed';
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

  Future<void> fetchUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.userProfile();

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        
        // Check if user is a student
        if (data.containsKey('type') && data['type'] == 'student') {
          if (data.containsKey('profile') && data['profile'] is Map) {
            _currentStudent = Student.fromJson(data['profile'] as Map<String, dynamic>);
          }
        }

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = result['error']?.toString();
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await ApiService.clearAuthToken();

      _isAuthenticated = false;
      _currentStudent = null;
      _authToken = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to logout: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Student student) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // TODO: Implement update profile endpoint in API if needed
      _currentStudent = student;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
