import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Backend base URL - Configure based on environment
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
  static const String apiVersion = '/v1';

  static String? _authToken;

  // Custom exceptions for API errors
  static const int timeoutDuration = 30; // seconds

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static String? getAuthToken() => _authToken;

  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Token $_authToken';
    }

    return headers;
  }

  static Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    try {
      // Try to parse as JSON
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData,
          'statusCode': response.statusCode,
        };
      } else {
        // Extract error message from response
        String errorMessage = 'An error occurred';

        if (responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        } else if (responseData.containsKey('detail')) {
          errorMessage = responseData['detail'].toString();
        } else if (responseData.containsKey('message')) {
          errorMessage = responseData['message'].toString();
        } else if (responseData is Map && responseData.isNotEmpty) {
          // Try to extract first error from validation errors
          final firstKey = responseData.keys.first;
          final firstValue = responseData[firstKey];
          if (firstValue is List && firstValue.isNotEmpty) {
            errorMessage = firstValue[0].toString();
          } else {
            errorMessage = firstValue.toString();
          }
        }

        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
          'details': responseData,
        };
      }
    } catch (e) {
      // Failed to parse as JSON
      return {
        'success': false,
        'error': response.statusCode >= 500
            ? 'Server error: ${response.statusCode}'
            : 'Invalid response format',
        'statusCode': response.statusCode,
        'raw_body': response.body,
      };
    }
  }

  // ============================================================================
  // AUTHENTICATION ENDPOINTS
  // ============================================================================

  static Future<Map<String, dynamic>> studentLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: timeoutDuration), onTimeout: () {
        throw Exception('Request timeout');
      });

      final result = await _handleResponse(response);

      // If login successful, save the token
      if (result['success'] && result['data'] is Map) {
        final data = result['data'] as Map<String, dynamic>;
        if (data.containsKey('token')) {
          await setAuthToken(data['token'].toString());
        }
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> studentRegister({
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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/student-register/'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password2': password2,
          'first_name': firstName,
          'last_name': lastName,
          'registration_number': registrationNumber,
          'institution': institution,
          'course': course,
          'academic_level': academicLevel,
          'phone': phone,
          'preferred_location': preferredLocation ?? '',
        }),
      ).timeout(const Duration(seconds: timeoutDuration), onTimeout: () {
        throw Exception('Request timeout');
      });

      final result = await _handleResponse(response);

      // If registration successful, save the token
      if (result['success'] && result['data'] is Map) {
        final data = result['data'] as Map<String, dynamic>;
        if (data.containsKey('token')) {
          await setAuthToken(data['token'].toString());
        }
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> userProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: _getHeaders(),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // ============================================================================
  // INSTITUTION ENDPOINTS
  // ============================================================================

  static Future<Map<String, dynamic>> getInstitutions({
    String? search,
    int page = 1,
  }) async {
    try {
      String url = '$baseUrl$apiVersion/institutions/';
      final params = <String, String>{};

      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      params['page'] = page.toString();

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _getHeaders(includeAuth: false))
          .timeout(const Duration(seconds: timeoutDuration), onTimeout: () {
        throw Exception('Request timeout');
      });

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getInstitution(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/institutions/$id/'),
        headers: _getHeaders(includeAuth: false),
      ).timeout(const Duration(seconds: timeoutDuration), onTimeout: () {
        throw Exception('Request timeout');
      });

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============================================================================
  // COURSE ENDPOINTS
  // ============================================================================

  static Future<Map<String, dynamic>> getCourses({
    int? department,
    String? level,
    String? search,
    int page = 1,
  }) async {
    try {
      String url = '$baseUrl$apiVersion/courses/';
      final params = <String, String>{};

      if (department != null) {
        params['department'] = department.toString();
      }
      if (level != null) {
        params['level'] = level;
      }
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      params['page'] = page.toString();

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _getHeaders(includeAuth: false))
          .timeout(const Duration(seconds: timeoutDuration), onTimeout: () {
        throw Exception('Request timeout');
      });

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getCourse(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/courses/$id/'),
        headers: _getHeaders(includeAuth: false),
      ).timeout(const Duration(seconds: timeoutDuration), onTimeout: () {
        throw Exception('Request timeout');
      });

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============================================================================
  // SKILL ENDPOINTS
  // ============================================================================

  static Future<Map<String, dynamic>> getSkills({
    String? search,
    int page = 1,
  }) async {
    try {
      String url = '$baseUrl$apiVersion/skills/';
      final params = <String, String>{};

      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      params['page'] = page.toString();

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _getHeaders(includeAuth: false))
          .timeout(const Duration(seconds: timeoutDuration), onTimeout: () {
        throw Exception('Request timeout');
      });

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============================================================================
  // STUDENT ENDPOINTS
  // ============================================================================

  static Future<Map<String, dynamic>> getStudents({
    int? institution,
    int? course,
    String? academicLevel,
    bool? isPlaced,
    String? search,
    int page = 1,
  }) async {
    try {
      String url = '$baseUrl$apiVersion/students/';
      final params = <String, String>{};

      if (institution != null) {
        params['institution'] = institution.toString();
      }
      if (course != null) {
        params['course'] = course.toString();
      }
      if (academicLevel != null) {
        params['academic_level'] = academicLevel;
      }
      if (isPlaced != null) {
        params['is_placed'] = isPlaced.toString();
      }
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      params['page'] = page.toString();

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _getHeaders(includeAuth: false));

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getStudent(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/students/$id/'),
        headers: _getHeaders(includeAuth: false),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/students/my_profile/'),
        headers: _getHeaders(),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateStudentSkills({
    required int studentId,
    required List<int> skillIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/students/$studentId/update_skills/'),
        headers: _getHeaders(),
        body: jsonEncode({
          'skill_ids': skillIds,
        }),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // ============================================================================
  // ORGANIZATION ENDPOINTS
  // ============================================================================

  static Future<Map<String, dynamic>> getOrganizations({
    bool? isVerified,
    String? industryType,
    String? search,
    int page = 1,
  }) async {
    try {
      String url = '$baseUrl$apiVersion/organizations/';
      final params = <String, String>{};

      if (isVerified != null) {
        params['is_verified'] = isVerified.toString();
      }
      if (industryType != null) {
        params['industry_type'] = industryType;
      }
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      params['page'] = page.toString();

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _getHeaders(includeAuth: false));

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getOrganization(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/organizations/$id/'),
        headers: _getHeaders(includeAuth: false),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getMyOrganization() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/organizations/my_profile/'),
        headers: _getHeaders(),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // ============================================================================
  // TRAINING OPPORTUNITY ENDPOINTS
  // ============================================================================

  static Future<Map<String, dynamic>> getTrainingOpportunities({
    int? organization,
    bool? isOpen,
    String? supportedLevels,
    List<int>? courses,
    bool? availableOnly,
    String? search,
    int page = 1,
  }) async {
    try {
      String url = '$baseUrl$apiVersion/training-opportunities/';
      final params = <String, String>{};

      if (organization != null) {
        params['organization'] = organization.toString();
      }
      if (isOpen != null) {
        params['is_open'] = isOpen.toString();
      }
      if (supportedLevels != null) {
        params['supported_levels'] = supportedLevels;
      }
      if (courses != null && courses.isNotEmpty) {
        params['courses'] = courses.join(',');
      }
      if (availableOnly != null) {
        params['available_only'] = availableOnly.toString();
      }
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      params['page'] = page.toString();

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _getHeaders(includeAuth: false));

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getTrainingOpportunity(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/training-opportunities/$id/'),
        headers: _getHeaders(includeAuth: false),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getMyOpportunities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/training-opportunities/my_opportunities/'),
        headers: _getHeaders(),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getMatchedOpportunities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/training-opportunities/matched_opportunities/'),
        headers: _getHeaders(),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // ============================================================================
  // APPLICATION ENDPOINTS
  // ============================================================================

  static Future<Map<String, dynamic>> getApplications({
    int? student,
    int? organization,
    String? status,
    String? search,
    int page = 1,
  }) async {
    try {
      String url = '$baseUrl$apiVersion/applications/';
      final params = <String, String>{};

      if (student != null) {
        params['student'] = student.toString();
      }
      if (organization != null) {
        params['organization'] = organization.toString();
      }
      if (status != null) {
        params['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      params['page'] = page.toString();

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _getHeaders());

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getApplication(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/applications/$id/'),
        headers: _getHeaders(),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> submitApplication({
    required int trainingOpportunityId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/applications/'),
        headers: _getHeaders(),
        body: jsonEncode({
          'training_opportunity_id': trainingOpportunityId,
        }),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> acceptApplication({
    required int applicationId,
    String? acceptanceLetter,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (acceptanceLetter != null) {
        body['acceptance_letter'] = acceptanceLetter;
      }
      if (startDate != null) {
        body['start_date'] = startDate;
      }
      if (endDate != null) {
        body['end_date'] = endDate;
      }

      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/applications/$applicationId/accept/'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> rejectApplication({
    required int applicationId,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/applications/$applicationId/reject/'),
        headers: _getHeaders(),
        body: jsonEncode({
          'reason': reason ?? '',
        }),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> withdrawApplication({
    required int applicationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/applications/$applicationId/withdraw/'),
        headers: _getHeaders(),
        body: jsonEncode({}),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // ============================================================================
  // NOTIFICATION ENDPOINTS
  // ============================================================================

  static Future<Map<String, dynamic>> getNotifications({
    bool? isRead,
    int page = 1,
  }) async {
    try {
      String url = '$baseUrl$apiVersion/notifications/';
      final params = <String, String>{};

      if (isRead != null) {
        params['is_read'] = isRead.toString();
      }
      params['page'] = page.toString();

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _getHeaders());

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/notifications/$id/mark_as_read/'),
        headers: _getHeaders(),
        body: jsonEncode({}),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/notifications/mark_all_as_read/'),
        headers: _getHeaders(),
        body: jsonEncode({}),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // ============================================================================
  // REVIEW ENDPOINTS
  // ============================================================================

  static Future<Map<String, dynamic>> getReviews({
    int? organization,
    int? rating,
    int page = 1,
  }) async {
    try {
      String url = '$baseUrl$apiVersion/reviews/';
      final params = <String, String>{};

      if (organization != null) {
        params['organization'] = organization.toString();
      }
      if (rating != null) {
        params['rating'] = rating.toString();
      }
      params['page'] = page.toString();

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri, headers: _getHeaders(includeAuth: false));

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> submitReview({
    required int organizationId,
    required int rating,
    required String title,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/reviews/'),
        headers: _getHeaders(),
        body: jsonEncode({
          'organization_id': organizationId,
          'rating': rating,
          'title': title,
          'comment': comment,
        }),
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}
