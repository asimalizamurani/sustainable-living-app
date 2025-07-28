import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (_authService.currentUser != null) {
        _currentUser = await _authService.getUserById(_authService.currentUser!.uid);
        setState(() {});
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF2E7D32),
              Colors.white,
            ],
            stops: [0.0, 0.2, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Account Settings
              _buildSettingsSection(
                'Account',
                Icons.person,
                [
                  _buildSettingsItem(
                    'Edit Profile',
                    Icons.edit,
                    const Color(0xFF2196F3),
                    () {
                      // TODO: Navigate to edit profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit Profile feature coming soon!'),
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    'Change Password',
                    Icons.lock,
                    const Color(0xFF9C27B0),
                    () {
                      _showChangePasswordDialog();
                    },
                  ),
                  _buildSettingsItem(
                    'Privacy Settings',
                    Icons.security,
                    const Color(0xFF607D8B),
                    () {
                      _showPrivacySettings();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // App Preferences
              _buildSettingsSection(
                'Preferences',
                Icons.settings,
                [
                  _buildSettingsItem(
                    'Notifications',
                    Icons.notifications,
                    const Color(0xFFFF9800),
                    () {
                      _showNotificationSettings();
                    },
                  ),
                  _buildSettingsItem(
                    'Language',
                    Icons.language,
                    const Color(0xFF4CAF50),
                    () {
                      _showLanguageSettings();
                    },
                  ),
                  _buildSettingsItem(
                    'Theme',
                    Icons.palette,
                    const Color(0xFF9C27B0),
                    () {
                      _showThemeSettings();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Data & Storage
              _buildSettingsSection(
                'Data & Storage',
                Icons.storage,
                [
                  _buildSettingsItem(
                    'Export Data',
                    Icons.download,
                    const Color(0xFF4CAF50),
                    () {
                      _exportData();
                    },
                  ),
                  _buildSettingsItem(
                    'Clear Cache',
                    Icons.clear_all,
                    const Color(0xFFFF9800),
                    () {
                      _clearCache();
                    },
                  ),
                  _buildSettingsItem(
                    'Delete Account',
                    Icons.delete_forever,
                    const Color(0xFFF44336),
                    () {
                      _showDeleteAccountDialog();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Support & About
              _buildSettingsSection(
                'Support & About',
                Icons.help,
                [
                  _buildSettingsItem(
                    'Help & FAQ',
                    Icons.help_outline,
                    const Color(0xFF2196F3),
                    () {
                      _showHelpAndFAQ();
                    },
                  ),
                  _buildSettingsItem(
                    'Contact Support',
                    Icons.support_agent,
                    const Color(0xFF4CAF50),
                    () {
                      _contactSupport();
                    },
                  ),
                  _buildSettingsItem(
                    'About App',
                    Icons.info,
                    const Color(0xFF607D8B),
                    () {
                      _showAboutApp();
                    },
                  ),
                  _buildSettingsItem(
                    'Terms of Service',
                    Icons.description,
                    const Color(0xFF9C27B0),
                    () {
                      _showTermsOfService();
                    },
                  ),
                  _buildSettingsItem(
                    'Privacy Policy',
                    Icons.privacy_tip,
                    const Color(0xFF607D8B),
                    () {
                      _showPrivacyPolicy();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> items) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF4CAF50),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          // Section Items
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
        const Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text == confirmPasswordController.text) {
                try {
                  await _authService.changePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error changing password: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Share Progress'),
              subtitle: Text('Allow others to see your sustainability progress'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Location Services'),
              subtitle: Text('Use location for local sustainability tips'),
              value: false,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Analytics'),
              subtitle: Text('Help improve the app with anonymous usage data'),
              value: true,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Challenge Reminders'),
              subtitle: Text('Get reminded about active challenges'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Daily Tips'),
              subtitle: Text('Receive daily eco-friendly tips'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Achievement Alerts'),
              subtitle: Text('Get notified when you earn achievements'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Weekly Reports'),
              subtitle: Text('Receive weekly sustainability reports'),
              value: false,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('English'),
              value: 'English',
              groupValue: _currentUser?.preferredLanguage ?? 'English',
              onChanged: (value) {
                // TODO: Update language preference
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Spanish'),
              value: 'Spanish',
              groupValue: _currentUser?.preferredLanguage ?? 'English',
              onChanged: (value) {
                // TODO: Update language preference
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('French'),
              value: 'French',
              groupValue: _currentUser?.preferredLanguage ?? 'English',
              onChanged: (value) {
                // TODO: Update language preference
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save language preference
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showThemeSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Light Theme'),
              value: 'light',
              groupValue: 'light',
              onChanged: (value) {
                // TODO: Update theme
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Dark Theme'),
              value: 'dark',
              groupValue: 'light',
              onChanged: (value) {
                // TODO: Update theme
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('System Default'),
              value: 'system',
              groupValue: 'light',
              onChanged: (value) {
                // TODO: Update theme
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save theme preference
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting your data...'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHelpAndFAQ() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Q: How do I track my carbon footprint?\n'
                'A: Use the Carbon Tracker feature to log your daily activities.\n\n'
                'Q: How do I earn eco points?\n'
                'A: Complete challenges and log sustainable activities.\n\n'
                'Q: Can I share my progress?\n'
                'A: Yes, you can share your achievements on social media.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact support at support@sustainableliving.com'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Sustainable Living'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Sustainable Living helps you track your environmental impact and make eco-friendly choices.',
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Carbon footprint tracking'),
            Text('• Sustainability challenges'),
            Text('• Eco tips and advice'),
            Text('• Achievement system'),
            Text('• Community features'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using this app, you agree to our terms of service. '
            'This includes proper use of the app, respecting other users, '
            'and following sustainable practices.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'We respect your privacy. Your data is used only to provide '
            'personalized sustainability recommendations and track your progress. '
            'We do not sell or share your personal information with third parties.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 