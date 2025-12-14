import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/organization_provider.dart';
import '../providers/application_provider.dart';
import '../theme/app_theme.dart';
import 'browse_organizations.dart';
import 'my_applications.dart';
import 'profile_screen.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_stats.dart';
import '../widgets/recent_activity.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    final student = context.read<AuthProvider>().currentStudent;
    if (student != null) {
      await context.read<ApplicationProvider>().fetchApplications(student.id);
      await context.read<OrganizationProvider>().fetchMatchedOrganizations(
        course: student.course,
        level: student.level,
        skills: student.skills,
        location: student.preferredLocation,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().currentStudent;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'SITMS',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                context.read<AuthProvider>().logout();
              },
              child: Tooltip(
                message: 'Logout',
                child: Icon(
                  Icons.logout,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final student = context.watch<AuthProvider>().currentStudent;

    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab(student);
      case 1:
        return const BrowseOrganizationsScreen();
      case 2:
        return const MyApplicationsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab(student);
    }
  }

  Widget _buildHomeTab(student) {
    if (student == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          DashboardHeader(student: student),
          const SizedBox(height: 24),
          QuickStats(student: student),
          const SizedBox(height: 24),
          RecentActivity(student: student),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
