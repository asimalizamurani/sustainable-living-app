import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';
import '../services/auth_service.dart';

class AdminChallengeManagement extends StatefulWidget {
  const AdminChallengeManagement({super.key});

  @override
  State<AdminChallengeManagement> createState() => _AdminChallengeManagementState();
}

class _AdminChallengeManagementState extends State<AdminChallengeManagement> {
  final AuthService _authService = AuthService();
  List<ChallengeModel> _challenges = [];
  bool _isLoading = true;

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
          .orderBy('createdAt', descending: true)
          .get();

      _challenges = snapshot.docs
          .map((doc) => ChallengeModel.fromMap(doc.data()))
          .toList();

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

  Future<void> _createChallenge() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateChallengeModal(),
    );

    if (result != null) {
      try {
        final challenge = ChallengeModel(
          title: result['title'],
          description: result['description'],
          category: result['category'],
          difficulty: result['difficulty'],
          ecoPointsReward: result['ecoPointsReward'],
          carbonFootprintReduction: result['carbonFootprintReduction'],
          startDate: result['startDate'],
          endDate: result['endDate'],
          requirements: result['requirements'],
          tips: result['tips'],
          createdAt: DateTime.now(),
          createdBy: _authService.currentUser?.uid,
        );

        await FirebaseFirestore.instance
            .collection('challenges')
            .add(challenge.toMap());

        _loadChallenges();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challenge created successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating challenge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleChallengeStatus(ChallengeModel challenge) async {
    try {
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challenge.id)
          .update({
        'isActive': !challenge.isActive,
      });

      _loadChallenges();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            challenge.isActive ? 'Challenge deactivated' : 'Challenge activated',
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating challenge: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteChallenge(ChallengeModel challenge) async {
    try {
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challenge.id)
          .delete();

      _loadChallenges();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challenge deleted successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting challenge: $e'),
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
          'Challenge Management',
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
        child: Column(
          children: [
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Challenges',
                      _challenges.length.toString(),
                      Icons.emoji_events,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Active',
                      _challenges.where((c) => c.isActive).length.toString(),
                      Icons.check_circle,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Inactive',
                      _challenges.where((c) => !c.isActive).length.toString(),
                      Icons.cancel,
                      const Color(0xFFF44336),
                    ),
                  ),
                ],
              ),
            ),

            // Challenges List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : _challenges.isEmpty
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
                                'No challenges created yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the + button to create your first challenge',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _challenges.length,
                          itemBuilder: (context, index) {
                            return _buildChallengeCard(_challenges[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChallenge,
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 4),
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
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeModel challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                top: Radius.circular(12),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(challenge.category),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              challenge.category.toString().split('.').last.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(challenge.difficulty),
                              borderRadius: BorderRadius.circular(8),
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
                    ],
                  ),
                ),
                Switch(
                  value: challenge.isActive,
                  onChanged: (value) => _toggleChallengeStatus(challenge),
                  activeColor: const Color(0xFF4CAF50),
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

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Edit challenge
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit challenge feature coming soon!'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteChallengeDialog(challenge),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
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

  void _showDeleteChallengeDialog(ChallengeModel challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Challenge'),
        content: Text(
          'Are you sure you want to delete "${challenge.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteChallenge(challenge);
              Navigator.pop(context);
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

class CreateChallengeModal extends StatefulWidget {
  const CreateChallengeModal({super.key});

  @override
  State<CreateChallengeModal> createState() => _CreateChallengeModalState();
}

class _CreateChallengeModalState extends State<CreateChallengeModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ecoPointsController = TextEditingController();
  final _carbonReductionController = TextEditingController();
  
  ChallengeCategory _selectedCategory = ChallengeCategory.lifestyle;
  ChallengeDifficulty _selectedDifficulty = ChallengeDifficulty.easy;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  final List<String> _requirements = [];
  final List<String> _tips = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ecoPointsController.dispose();
    _carbonReductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Create New Challenge',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Challenge Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category and Difficulty
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ChallengeCategory>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: ChallengeCategory.values.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category.toString().split('.').last.toUpperCase(),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<ChallengeDifficulty>(
                            value: _selectedDifficulty,
                            decoration: const InputDecoration(
                              labelText: 'Difficulty',
                              border: OutlineInputBorder(),
                            ),
                            items: ChallengeDifficulty.values.map((difficulty) {
                              return DropdownMenuItem(
                                value: difficulty,
                                child: Text(
                                  difficulty.toString().split('.').last.toUpperCase(),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Rewards
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ecoPointsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Eco Points Reward',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _carbonReductionController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'CO₂ Reduction (kg)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Range
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Start Date'),
                            subtitle: Text(_formatDate(_startDate)),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _selectStartDate,
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('End Date'),
                            subtitle: Text(_formatDate(_endDate)),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _selectEndDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createChallenge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _createChallenge() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'ecoPointsReward': int.parse(_ecoPointsController.text),
        'carbonFootprintReduction': int.parse(_carbonReductionController.text),
        'startDate': _startDate,
        'endDate': _endDate,
        'requirements': _requirements,
        'tips': _tips,
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 