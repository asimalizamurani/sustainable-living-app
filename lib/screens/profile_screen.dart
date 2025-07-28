import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/achievement_model.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  final List<AchievementModel> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAchievements();
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

  Future<void> _loadAchievements() async {
    try {
      // TODO: Load user achievements from Firestore
      // This would require a separate collection for user achievements
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading achievements: $e');
      setState(() {
        _isLoading = false;
      });
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
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
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
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4CAF50),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header
                    _buildProfileHeader(),
                    
                    // Stats Section
                    _buildStatsSection(),
                    
                    // Achievements Section
                    _buildAchievementsSection(),
                    
                    // Menu Items
                    _buildMenuSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Image
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF4CAF50),
                    backgroundImage: _currentUser?.profileImage != null
                        ? NetworkImage(_currentUser!.profileImage!)
                        : null,
                    child: _currentUser?.profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // User Info
              Text(
                _currentUser?.name ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currentUser?.email ?? 'user@example.com',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentUser?.role == UserRole.admin ? 'ADMIN' : 'USER',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Sustainability Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Eco Points',
                      '${_currentUser?.ecoPoints ?? 0}',
                      Icons.star,
                      const Color(0xFFFFD700),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Carbon Saved',
                      '${_currentUser?.carbonFootprint ?? 0} kg',
                      Icons.eco,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Challenges',
                      '${_currentUser?.challengesCompleted ?? 0}',
                      Icons.emoji_events,
                      const Color(0xFFFF9800),
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 30,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    '${_currentUser?.achievements.length ?? 0} unlocked',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_currentUser?.achievements.isEmpty ?? true)
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.military_tech_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No achievements yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Complete challenges to earn achievements!',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _currentUser!.achievements.length,
                  itemBuilder: (context, index) {
                    return _buildAchievementItem(_currentUser!.achievements[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementItem(String achievementName) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.military_tech,
            color: Color(0xFF4CAF50),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            achievementName,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildMenuItem(
              'Settings',
              Icons.settings,
              const Color(0xFF2196F3),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              'Help & Support',
              Icons.help_outline,
              const Color(0xFF9C27B0),
              () {
                // TODO: Navigate to help screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help & Support coming soon!'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              },
            ),
            _buildMenuItem(
              'About',
              Icons.info_outline,
              const Color(0xFF607D8B),
              () {
                _showAboutDialog();
              },
            ),
            _buildMenuItem(
              'Logout',
              Icons.logout,
              const Color(0xFFF44336),
              _logout,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool showDivider = true,
  }) {
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
        if (showDivider)
          const Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
          ),
      ],
    );
  }

  void _showAboutDialog() {
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sustainable Living is your companion app for making eco-friendly choices and tracking your environmental impact.',
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
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }
} 