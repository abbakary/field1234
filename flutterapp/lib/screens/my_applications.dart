import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/application_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/application_card.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  String _selectedTab = 'All';

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() {
    final student = context.read<AuthProvider>().currentStudent;
    if (student != null) {
      context.read<ApplicationProvider>().fetchApplications(student.id);
    }
  }

  List<String> get _tabOptions => [
    'All',
    'Pending',
    'Accepted',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('My Applications'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabOptions.map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(color: AppTheme.borderColor),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Applications List
          Expanded(
            child: Consumer<ApplicationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var applications = provider.applications;

                // Filter by tab
                if (_selectedTab == 'Pending') {
                  applications = applications
                      .where((app) =>
                          app.status.toString().contains('pending'))
                      .toList();
                } else if (_selectedTab == 'Accepted') {
                  applications = applications
                      .where((app) =>
                          app.status.toString().contains('accepted'))
                      .toList();
                } else if (_selectedTab == 'Rejected') {
                  applications = applications
                      .where((app) =>
                          app.status.toString().contains('rejected'))
                      .toList();
                }

                if (applications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No applications yet',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to browse organizations
                          },
                          child: const Text('Browse Organizations'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    return ApplicationCard(application: app);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
