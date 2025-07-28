import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import '../models/eco_tip_model.dart';

class AdminAnalytics extends StatefulWidget {
  const AdminAnalytics({super.key});

  @override
  State<AdminAnalytics> createState() => _AdminAnalyticsState();
}

class _AdminAnalyticsState extends State<AdminAnalytics> {
  List<UserModel> _users = [];
  List<ChallengeModel> _challenges = [];
  List<EcoTipModel> _tips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load users
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      _users = usersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      // Load challenges
      final challengesSnapshot = await FirebaseFirestore.instance
          .collection('challenges')
          .get();

      _challenges = challengesSnapshot.docs
          .map((doc) => ChallengeModel.fromMap(doc.data()))
          .toList();

      // Load tips
      final tipsSnapshot = await FirebaseFirestore.instance
          .collection('eco_tips')
          .get();

      _tips = tipsSnapshot.docs
          .map((doc) => EcoTipModel.fromMap(doc.data()))
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get _totalUsers => _users.length;
  int get _totalChallenges => _challenges.length;
  int get _totalTips => _tips.length;
  int get _activeChallenges => _challenges.where((c) => c.isActive).length;
  int get _totalEcoPoints => _users.fold(0, (sum, user) => sum + user.ecoPoints);
  int get _totalCarbonSaved => _users.fold(0, (sum, user) => sum + user.carbonFootprint);
  int get _totalChallengesCompleted => _users.fold(0, (sum, user) => sum + user.challengesCompleted);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics & Reports',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            )
          : Container(
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
                    // Overview Stats
                    _buildOverviewSection(),
                    const SizedBox(height: 24),

                    // User Engagement Chart
                    _buildUserEngagementChart(),
                    const SizedBox(height: 24),

                    // Challenge Performance
                    _buildChallengePerformanceSection(),
                    const SizedBox(height: 24),

                    // Top Users
                    _buildTopUsersSection(),
                    const SizedBox(height: 24),

                    // Category Distribution
                    _buildCategoryDistributionSection(),
                    const SizedBox(height: 24),

                    // Recent Activity
                    _buildRecentActivitySection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewSection() {
    return Card(
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
              'Platform Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewStat(
                    'Total Users',
                    _totalUsers.toString(),
                    Icons.people,
                    const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewStat(
                    'Active Challenges',
                    _activeChallenges.toString(),
                    Icons.emoji_events,
                    const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewStat(
                    'Total Eco Points',
                    _totalEcoPoints.toString(),
                    Icons.star,
                    const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewStat(
                    'CO₂ Saved (kg)',
                    _totalCarbonSaved.toString(),
                    Icons.eco,
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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
    );
  }

  Widget _buildUserEngagementChart() {
    return Card(
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
              'User Engagement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(2.6, 2),
                        const FlSpot(4.9, 5),
                        const FlSpot(6.8, 3.1),
                        const FlSpot(8, 4),
                        const FlSpot(9.5, 3),
                        const FlSpot(11, 4),
                      ],
                      isCurved: true,
                      color: const Color(0xFF4CAF50),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengePerformanceSection() {
    return Card(
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
              'Challenge Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceStat(
                    'Total Challenges',
                    _totalChallenges.toString(),
                    Icons.assignment,
                    const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceStat(
                    'Completed',
                    _totalChallengesCompleted.toString(),
                    Icons.check_circle,
                    const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceStat(
                    'Success Rate',
                    '${((_totalChallengesCompleted / _totalChallenges) * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStat(String title, String value, IconData icon, Color color) {
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
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopUsersSection() {
    final topUsers = _users
        .where((user) => user.ecoPoints > 0)
        .toList()
      ..sort((a, b) => b.ecoPoints.compareTo(a.ecoPoints));

    return Card(
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
              'Top Users',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            if (topUsers.isEmpty)
              const Center(
                child: Text(
                  'No users with eco points yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...topUsers.take(5).map((user) => _buildTopUserTile(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUserTile(UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF4CAF50),
        child: Text(
          user.name?.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.name ?? 'Unknown User',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${user.challengesCompleted} challenges completed'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${user.ecoPoints} pts',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionSection() {
    final challengeCategories = _challenges.fold<Map<String, int>>({}, (map, challenge) {
      final category = challenge.category.toString().split('.').last;
      map[category] = (map[category] ?? 0) + 1;
      return map;
    });

    return Card(
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
              'Challenge Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: challengeCategories.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${entry.value}',
                      color: _getCategoryColor(entry.key),
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
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
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              Icons.person_add,
              'New user registered',
              '2 minutes ago',
              const Color(0xFF4CAF50),
            ),
            _buildActivityItem(
              Icons.emoji_events,
              'Challenge completed',
              '5 minutes ago',
              const Color(0xFFFF9800),
            ),
            _buildActivityItem(
              Icons.star,
              'Eco points earned',
              '10 minutes ago',
              const Color(0xFFFFD700),
            ),
            _buildActivityItem(
              Icons.lightbulb,
              'New tip published',
              '15 minutes ago',
              const Color(0xFF2196F3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time, Color color) {
    return ListTile(
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
      subtitle: Text(
        time,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'energy':
        return const Color(0xFFFF9800);
      case 'water':
        return const Color(0xFF2196F3);
      case 'waste':
        return const Color(0xFF795548);
      case 'transport':
        return const Color(0xFF9C27B0);
      case 'food':
        return const Color(0xFF4CAF50);
      case 'lifestyle':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF4CAF50);
    }
  }
} 