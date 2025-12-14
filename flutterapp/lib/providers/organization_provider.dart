import 'package:flutter/foundation.dart';
import '../models/organization.dart';

class OrganizationProvider extends ChangeNotifier {
  List<Organization> _organizations = [];
  List<Organization> _matchedOrganizations = [];
  Organization? _selectedOrganization;
  bool _isLoading = false;
  String? _errorMessage;

  List<Organization> get organizations => _organizations;
  List<Organization> get matchedOrganizations => _matchedOrganizations;
  Organization? get selectedOrganization => _selectedOrganization;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrganizations() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1500));

      _organizations = _generateMockOrganizations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMatchedOrganizations({
    required String course,
    required String level,
    required List<String> skills,
    String? location,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1500));

      _matchedOrganizations = _generateMockOrganizations()
          .where((org) {
            final courseMatch = org.supportedCourses.contains(course);
            final levelMatch = org.supportedLevels.contains(level);
            final skillMatch = org.requiredSkills
                .any((skill) => skills.contains(skill));
            final locationMatch = location == null ||
                org.location.toLowerCase().contains(location.toLowerCase());
            
            return courseMatch && levelMatch && skillMatch && locationMatch;
          })
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getOrganizationDetail(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 800));

      _selectedOrganization = _generateMockOrganizations()
          .firstWhere((org) => org.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Organization> _generateMockOrganizations() {
    return [
      Organization(
        id: '1',
        name: 'TechCorp Tanzania',
        industryType: 'Information Technology',
        location: 'Dar es Salaam',
        description: 'Leading technology company providing innovative solutions for business transformation.',
        supportedCourses: ['Information Technology', 'Computer Science', 'Software Engineering'],
        supportedLevels: ['Diploma', 'Degree'],
        requiredSkills: ['Python', 'Web Development', 'Database Design'],
        totalSlots: 10,
        remainingSlots: 3,
        trainingDuration: '3 months',
        logoUrl: null,
        website: 'www.techcorp.co.tz',
        email: 'careers@techcorp.co.tz',
        phone: '+255123456789',
        rating: 4.8,
        reviewCount: 45,
        createdAt: DateTime.now(),
      ),
      Organization(
        id: '2',
        name: 'Construction & Engineering Ltd',
        industryType: 'Engineering',
        location: 'Dar es Salaam',
        description: 'Major construction and engineering company handling large-scale infrastructure projects.',
        supportedCourses: ['Civil Engineering', 'Mechanical Engineering'],
        supportedLevels: ['Degree'],
        requiredSkills: ['CAD', 'Project Management', 'Problem Solving'],
        totalSlots: 8,
        remainingSlots: 5,
        trainingDuration: '4 months',
        logoUrl: null,
        website: 'www.ceeng.co.tz',
        email: 'internship@ceeng.co.tz',
        phone: '+255987654321',
        rating: 4.6,
        reviewCount: 32,
        createdAt: DateTime.now(),
      ),
      Organization(
        id: '3',
        name: 'Finance Solutions Africa',
        industryType: 'Finance & Banking',
        location: 'Dar es Salaam',
        description: 'Financial services organization providing banking and investment solutions.',
        supportedCourses: ['Accounting', 'Business Administration', 'Finance'],
        supportedLevels: ['Diploma', 'Degree'],
        requiredSkills: ['Financial Analysis', 'Excel', 'Communication'],
        totalSlots: 15,
        remainingSlots: 8,
        trainingDuration: '3 months',
        logoUrl: null,
        website: 'www.financeafrica.co.tz',
        email: 'careers@financeafrica.co.tz',
        phone: '+255555666777',
        rating: 4.5,
        reviewCount: 28,
        createdAt: DateTime.now(),
      ),
      Organization(
        id: '4',
        name: 'Healthcare Systems Ltd',
        industryType: 'Healthcare',
        location: 'Arusha',
        description: 'Healthcare provider offering medical services and health technology solutions.',
        supportedCourses: ['Nursing', 'Medical Technology', 'Public Health'],
        supportedLevels: ['Diploma', 'Degree'],
        requiredSkills: ['Patient Care', 'Communication', 'Research'],
        totalSlots: 12,
        remainingSlots: 4,
        trainingDuration: '3 months',
        logoUrl: null,
        website: 'www.healthcaresystems.co.tz',
        email: 'internship@healthcaresystems.co.tz',
        phone: '+255111222333',
        rating: 4.7,
        reviewCount: 38,
        createdAt: DateTime.now(),
      ),
      Organization(
        id: '5',
        name: 'Agribusiness Innovations',
        industryType: 'Agriculture',
        location: 'Morogoro',
        description: 'Agricultural company focused on sustainable farming and food production.',
        supportedCourses: ['Agricultural Science', 'Business Administration'],
        supportedLevels: ['Diploma', 'Degree'],
        requiredSkills: ['Data Analysis', 'Communication', 'Problem Solving'],
        totalSlots: 20,
        remainingSlots: 15,
        trainingDuration: '4 months',
        logoUrl: null,
        website: 'www.agribiz.co.tz',
        email: 'careers@agribiz.co.tz',
        phone: '+255444555666',
        rating: 4.4,
        reviewCount: 22,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
