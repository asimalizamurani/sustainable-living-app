import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';
import '../services/auth_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final AuthService _authService = AuthService();
  List<ChallengeModel> _challenges = [];
  final List<ChallengeModel> _userChallenges = [];
  bool _isLoading = true;
  ChallengeCategory _selectedCategory = ChallengeCategory.lifestyle;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('challenges')
          .where('isActive', isEqualTo: true)
          .get();

      _challenges = snapshot.docs
          .map((doc) => ChallengeModel.fromMap(doc.data()))
          .toList();

      // TODO: Load user's active challenges
      // This would require a separate collection for user challenges

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading challenges: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _joinChallenge(ChallengeModel challenge) async {
    try {
      // TODO: Implement join challenge logic
      // This would add the challenge to user's active challenges
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined ${challenge.title}!'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error joining challenge: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<ChallengeModel> get _filteredChallenges {
    if (_selectedCategory == ChallengeCategory.lifestyle) {
      return _challenges;
    }
    return _challenges
        .where((challenge) => challenge.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sustainability Challenges',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
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
        child: Column(
          children: [
            // Category Filter
            Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ChallengeCategory.values.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          category.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            color: _selectedCategory == category
                                ? Colors.white
                                : const Color(0xFF4CAF50),
                          ),
                        ),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF4CAF50),
                        checkmarkColor: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : _filteredChallenges.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No challenges available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredChallenges.length,
                          itemBuilder: (context, index) {
                            return _buildChallengeCard(_filteredChallenges[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeModel challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Challenge Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(challenge.category).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(challenge.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(challenge.category),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.category.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getCategoryColor(challenge.category),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(challenge.difficulty),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    challenge.difficulty.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Challenge Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Challenge Stats
                Row(
                  children: [
                    _buildStatItem(
                      Icons.star,
                      '${challenge.ecoPointsReward}',
                      'Points',
                      const Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      Icons.eco,
                      '${challenge.carbonFootprintReduction}',
                      'CO₂ Saved',
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      Icons.people,
                      '${challenge.participantsCount}',
                      'Participants',
                      const Color(0xFF2196F3),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Challenge Duration
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(challenge.startDate)} - ${_formatDate(challenge.endDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Requirements
                if (challenge.requirements.isNotEmpty) ...[
                  const Text(
                    'Requirements:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...challenge.requirements.map((requirement) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            requirement,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                ],

                // Join Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _joinChallenge(challenge),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Join Challenge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.energy:
        return const Color(0xFFFF9800);
      case ChallengeCategory.water:
        return const Color(0xFF2196F3);
      case ChallengeCategory.waste:
        return const Color(0xFF795548);
      case ChallengeCategory.transport:
        return const Color(0xFF9C27B0);
      case ChallengeCategory.food:
        return const Color(0xFF4CAF50);
      case ChallengeCategory.lifestyle:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getCategoryIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.energy:
        return Icons.electric_bolt;
      case ChallengeCategory.water:
        return Icons.water_drop;
      case ChallengeCategory.waste:
        return Icons.delete;
      case ChallengeCategory.transport:
        return Icons.directions_car;
      case ChallengeCategory.food:
        return Icons.restaurant;
      case ChallengeCategory.lifestyle:
        return Icons.eco;
    }
  }

  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return const Color(0xFF4CAF50);
      case ChallengeDifficulty.medium:
        return const Color(0xFFFF9800);
      case ChallengeDifficulty.hard:
        return const Color(0xFFF44336);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 