import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  Student? _currentStudent;
  String? _authToken;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  Student? get currentStudent => _currentStudent;
  String? get authToken => _authToken;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    final studentJson = prefs.getString('student');
    
    if (_authToken != null && studentJson != null) {
      _isAuthenticated = true;      
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _errorMessage = null;
      
      final prefs = await SharedPreferences.getInstance();
      _authToken = 'token_$email';
      
      _currentStudent = Student(
        id: '1',
        fullName: 'John Doe',
        registrationNumber: 'REG001',
        institution: 'University of Dar es Salaam',
        level: 'Degree',
        course: 'Information Technology',
        department: 'Engineering',
        skills: ['Python', 'Web Development', 'Database Design'],
        preferredLocation: 'Dar es Salaam',
        email: email,
        phone: '+255123456789',
        createdAt: DateTime.now(),
      );
      
      await prefs.setString('auth_token', _authToken!);
      await prefs.setString('student', _currentStudent!.id);
      
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String registrationNumber,
    required String institution,
    required String level,
    required String course,
    required String department,
    required List<String> skills,
    required String preferredLocation,
    required String phone,
  }) async {
    try {
      _errorMessage = null;
      
      final prefs = await SharedPreferences.getInstance();
      _authToken = 'token_$email';
      
      _currentStudent = Student(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        registrationNumber: registrationNumber,
        institution: institution,
        level: level,
        course: course,
        department: department,
        skills: skills,
        preferredLocation: preferredLocation,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );
      
      await prefs.setString('auth_token', _authToken!);
      await prefs.setString('student', _currentStudent!.id);
      
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('student');
      
      _isAuthenticated = false;
      _currentStudent = null;
      _authToken = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile(Student student) async {
    try {
      _currentStudent = student;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
