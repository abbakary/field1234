import 'package:flutter/foundation.dart';
import '../models/organization.dart';
import '../services/api_service.dart';

class OrganizationProvider extends ChangeNotifier {
  List<Organization> _organizations = [];
  List<Organization> _matchedOpportunities = [];
  Organization? _selectedOrganization;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;

  List<Organization> get organizations => _organizations;
  List<Organization> get matchedOpportunities => _matchedOpportunities;
  Organization? get selectedOrganization => _selectedOrganization;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  Future<void> fetchOrganizations({
    bool? isVerified,
    String? industryType,
    String? search,
    int page = 1,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.getOrganizations(
        isVerified: isVerified,
        industryType: industryType,
        search: search,
        page: page,
      );

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        
        // Handle pagination
        if (data.containsKey('results')) {
          // Standard DRF pagination response
          final results = data['results'] as List;
          _organizations = results.map((org) {
            return Organization.fromJson(org as Map<String, dynamic>);
          }).toList();
          
          // Extract pagination info
          _currentPage = page;
          _totalPages = ((data['count'] ?? 0) as int) ~/ 20 + 1;
        } else if (data is List) {
          // Simple list response
          _organizations = data.map((org) {
            return Organization.fromJson(org as Map<String, dynamic>);
          }).toList();
        } else {
          _organizations = [];
        }

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to fetch organizations';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMatchedOpportunities() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.getMatchedOpportunities();

      if (result['success']) {
        final data = result['data'] as List;
        _matchedOpportunities = data.map((opp) {
          return Organization.fromJson(opp as Map<String, dynamic>);
        }).toList();

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to fetch matched opportunities';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getOrganizationDetail(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await ApiService.getOrganization(id);

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        _selectedOrganization = Organization.fromJson(data);

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = result['error']?.toString() ?? 'Failed to fetch organization details';
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
    _organizations = [];
    _matchedOpportunities = [];
    _selectedOrganization = null;
    _errorMessage = null;
    _currentPage = 1;
    _totalPages = 1;
    notifyListeners();
  }
}
