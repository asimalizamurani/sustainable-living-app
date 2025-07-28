import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'admin_user_management.dart';
import 'admin_challenge_management.dart';
import 'admin_tips_management.dart';
import 'admin_analytics.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  int _totalUsers = 0;
  int _totalChallenges = 0;
  int _totalTips = 0;
  int _activeChallenges = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Get current user
      if (_authService.currentUser != null) {
        _currentUser = await _authService.getUserById(_authService.currentUser!.uid);
      }

      // Get statistics
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final challengesSnapshot = await FirebaseFirestore.instance.collection('challenges').get();
      final tipsSnapshot = await FirebaseFirestore.instance.collection('eco_tips').get();

      setState(() {
        _totalUsers = usersSnapshot.docs.length;
        _totalChallenges = challengesSnapshot.docs.length;
        _totalTips = tipsSnapshot.docs.length;
        _activeChallenges = challengesSnapshot.docs
            .where((doc) => doc.data()['isActive'] == true)
            .length;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
              Colors.white,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF4CAF50),
                        child: Icon(
                          _currentUser?.profileImage != null 
                              ? Icons.person 
                              : Icons.admin_panel_settings,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${_currentUser?.name ?? 'Admin'}!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Manage your sustainable living platform',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Section
              const Text(
                'Platform Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Total Users',
                    _totalUsers.toString(),
                    Icons.people,
                    const Color(0xFF4CAF50),
                  ),
                  _buildStatCard(
                    'Active Challenges',
                    _activeChallenges.toString(),
                    Icons.emoji_events,
                    const Color(0xFFFF9800),
                  ),
                  _buildStatCard(
                    'Total Challenges',
                    _totalChallenges.toString(),
                    Icons.assignment,
                    const Color(0xFF2196F3),
                  ),
                  _buildStatCard(
                    'Eco Tips',
                    _totalTips.toString(),
                    Icons.lightbulb,
                    const Color(0xFF9C27B0),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Management Section
              const Text(
                'Management Tools',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              _buildManagementCard(
                'User Management',
                'Manage users, roles, and permissions',
                Icons.people_outline,
                const Color(0xFF4CAF50),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminUserManagement(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildManagementCard(
                'Challenge Management',
                'Create and manage sustainability challenges',
                Icons.emoji_events_outlined,
                const Color(0xFFFF9800),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminChallengeManagement(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildManagementCard(
                'Eco Tips Management',
                'Manage educational content and tips',
                Icons.lightbulb_outline,
                const Color(0xFF2196F3),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminTipsManagement(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildManagementCard(
                'Analytics & Reports',
                'View platform analytics and insights',
                Icons.analytics_outlined,
                const Color(0xFF9C27B0),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminAnalytics(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement create challenge
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Create Challenge feature coming soon!'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Challenge'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement create tip
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Create Tip feature coming soon!'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('New Tip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
} 