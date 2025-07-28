import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sustainable_living_app/leader_board_screen.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import '../models/eco_tip_model.dart';
import 'challenges_screen.dart';
import 'eco_tips_screen.dart';
import 'carbon_tracker_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  int _selectedIndex = 0;
  List<ChallengeModel> _featuredChallenges = [];
  List<EcoTipModel> _featuredTips = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFeaturedContent();
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

  Future<void> _loadFeaturedContent() async {
    try {
      // Load featured challenges
      final challengesSnapshot = await FirebaseFirestore.instance
          .collection('challenges')
          .where('isActive', isEqualTo: true)
          .limit(3)
          .get();

      _featuredChallenges = challengesSnapshot.docs
          .map((doc) => ChallengeModel.fromMap(doc.data()))
          .toList();

      // Load featured tips
      final tipsSnapshot = await FirebaseFirestore.instance
          .collection('eco_tips')
          .where('isFeatured', isEqualTo: true)
          .limit(3)
          .get();

      _featuredTips = tipsSnapshot.docs
          .map((doc) => EcoTipModel.fromMap(doc.data()))
          .toList();

      setState(() {});
    } catch (e) {
      print('Error loading featured content: $e');
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          const ChallengesScreen(),
          const EcoTipsScreen(),
          const CarbonTrackerScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Challenges',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sustainable Living',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
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
              Color(0xFF4CAF50),
              Color(0xFF2E7D32),
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
                        backgroundImage: _currentUser?.profileImage != null
                            ? NetworkImage(_currentUser!.profileImage!)
                            : null,
                        child: _currentUser?.profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${_currentUser?.name ?? 'User'}!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Continue your sustainable journey',
                              style: const TextStyle(
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

              // Stats Section
              const Text(
                'Your Progress',
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
                    child: _buildStatCard(
                      'Eco Points',
                      '${_currentUser?.ecoPoints ?? 0}',
                      Icons.star,
                      const Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Carbon Saved',
                      '${_currentUser?.carbonFootprint ?? 0} kg',
                      Icons.eco,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Challenges',
                      '${_currentUser?.challengesCompleted ?? 0}',
                      Icons.emoji_events,
                      const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Achievements',
                      '${_currentUser?.achievements.length ?? 0}',
                      Icons.military_tech,
                      const Color(0xFF9C27B0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

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
                    child: _buildQuickActionCard(
                      'Track Activity',
                      Icons.add_circle_outline,
                      const Color(0xFF4CAF50),
                      () {
                        setState(() {
                          _selectedIndex = 3; // Carbon Tracker
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      'Leaderboard',
                      Icons.leaderboard,
                      const Color(0xFFFF9800),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaderBoardScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Featured Challenges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Challenges',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1; // Challenges
                      });
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_featuredChallenges.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _featuredChallenges.length,
                    itemBuilder: (context, index) {
                      final challenge = _featuredChallenges[index];
                      return _buildChallengeCard(challenge);
                    },
                  ),
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'No featured challenges available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Featured Tips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Eco Tips',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2; // Tips
                      });
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_featuredTips.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _featuredTips.length,
                  itemBuilder: (context, index) {
                    final tip = _featuredTips[index];
                    return _buildTipCard(tip);
                  },
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'No eco tips available',
                        style: TextStyle(color: Colors.grey),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeModel challenge) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.emoji_events,
                  size: 40,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${challenge.ecoPointsReward} points',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(EcoTipModel tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lightbulb,
            color: Color(0xFF4CAF50),
          ),
        ),
        title: Text(
          tip.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          tip.description,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          // TODO: Navigate to tip detail
        },
      ),
    );
  }
} 