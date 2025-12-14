import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/organization_provider.dart';
import '../theme/app_theme.dart';
import 'organization_detail.dart';
import '../widgets/organization_card.dart';

class BrowseOrganizationsScreen extends StatefulWidget {
  const BrowseOrganizationsScreen({Key? key}) : super(key: key);

  @override
  State<BrowseOrganizationsScreen> createState() =>
      _BrowseOrganizationsScreenState();
}

class _BrowseOrganizationsScreenState extends State<BrowseOrganizationsScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    context.read<OrganizationProvider>().fetchOrganizations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filterOptions => [
    'All',
    'Available Only',
    'Highest Rated',
    'Most Popular',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search organizations...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  // Filters
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filterOptions.length,
                      itemBuilder: (context, index) {
                        final filter = _filterOptions[index];
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedFilter = filter),
                            backgroundColor: Colors.white,
                            selectedColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : AppTheme.borderColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Organizations List
            Expanded(
              child: Consumer<OrganizationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var organizations = provider.organizations;

                  // Apply search filter
                  if (_searchController.text.isNotEmpty) {
                    organizations = organizations.where((org) {
                      return org.name.toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          ) ||
                          org.industryType.toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              ) ||
                          org.location.toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              );
                    }).toList();
                  }

                  // Apply filters
                  if (_selectedFilter == 'Available Only') {
                    organizations =
                        organizations.where((org) => org.isSlotsAvailable).toList();
                  } else if (_selectedFilter == 'Highest Rated') {
                    organizations.sort((a, b) => b.rating.compareTo(a.rating));
                  }

                  if (organizations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No organizations found',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: organizations.length,
                    itemBuilder: (context, index) {
                      final org = organizations[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrganizationDetailScreen(organizationId: org.id),
                            ),
                          );
                        },
                        child: OrganizationCard(organization: org),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
