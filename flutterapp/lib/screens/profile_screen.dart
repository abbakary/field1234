import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().currentStudent;

    if (student == null) {
      return const Center(child: Text('No student data'));
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: TextButton(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                child: Text(_isEditing ? 'Done' : 'Edit'),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        student.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student.fullName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    student.registrationNumber,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Profile Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Academic Information
                  _buildSection(
                    context,
                    title: 'Academic Information',
                    items: [
                      _buildProfileItem(
                        label: 'Institution',
                        value: student.institutionName ?? '',
                      ),
                      _buildProfileItem(
                        label: 'Level',
                        value: student.level,
                      ),
                      _buildProfileItem(
                        label: 'Course',
                        value: student.courseName ?? '',
                      ),
                      _buildProfileItem(
                        label: 'Department',
                        value: student.departmentName ?? '',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Contact Information
                  _buildSection(
                    context,
                    title: 'Contact Information',
                    items: [
                      _buildProfileItem(
                        label: 'Email',
                        value: student.email,
                      ),
                      _buildProfileItem(
                        label: 'Phone',
                        value: student.phone,
                      ),
                      _buildProfileItem(
                        label: 'Preferred Location',
                        value: student.preferredLocation,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Skills
                  _buildSection(
                    context,
                    title: 'Skills',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: student.skills.map((skill) {
                        return Chip(
                          label: Text(skill.name),
                          backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            color: AppTheme.primaryColor,
                          ),
                          onDeleted: _isEditing
                              ? () {
                                  // Handle skill deletion
                                }
                              : null,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Account Settings
                  _buildSection(
                    context,
                    title: 'Account Settings',
                    items: [
                      _buildSettingItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        subtitle: 'Manage notification preferences',
                      ),
                      _buildSettingItem(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy & Security',
                        subtitle: 'Manage your privacy settings',
                      ),
                      _buildSettingItem(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        subtitle: 'Get help or contact support',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    List<Widget>? items,
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: items != null
                ? List.generate(
                    items.length,
                    (index) => Column(
                      children: [
                        items[index],
                        if (index < items.length - 1) ...[
                          const SizedBox(height: 12),
                          Divider(color: AppTheme.borderColor),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  )
                : [child ?? const SizedBox()],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
