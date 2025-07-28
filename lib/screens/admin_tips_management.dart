import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/eco_tip_model.dart';
import '../services/auth_service.dart';

class AdminTipsManagement extends StatefulWidget {
  const AdminTipsManagement({super.key});

  @override
  State<AdminTipsManagement> createState() => _AdminTipsManagementState();
}

class _AdminTipsManagementState extends State<AdminTipsManagement> {
  final AuthService _authService = AuthService();
  List<EcoTipModel> _tips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('eco_tips')
          .orderBy('createdAt', descending: true)
          .get();

      _tips = snapshot.docs
          .map((doc) => EcoTipModel.fromMap(doc.data()))
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tips: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTip() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTipModal(),
    );

    if (result != null) {
      try {
        final tip = EcoTipModel(
          title: result['title'],
          description: result['description'],
          content: result['content'],
          category: result['category'],
          ecoPointsReward: result['ecoPointsReward'],
          isFeatured: result['isFeatured'],
          tags: result['tags'],
          createdAt: DateTime.now(),
          createdBy: _authService.currentUser?.uid,
        );

        await FirebaseFirestore.instance
            .collection('eco_tips')
            .add(tip.toMap());

        _loadTips();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eco tip created successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating tip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFeaturedStatus(EcoTipModel tip) async {
    try {
      await FirebaseFirestore.instance
          .collection('eco_tips')
          .doc(tip.id)
          .update({
        'isFeatured': !tip.isFeatured,
      });

      _loadTips();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tip.isFeatured ? 'Tip removed from featured' : 'Tip added to featured',
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating tip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTip(EcoTipModel tip) async {
    try {
      await FirebaseFirestore.instance
          .collection('eco_tips')
          .doc(tip.id)
          .delete();

      _loadTips();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tip deleted successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting tip: $e'),
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
          'Eco Tips Management',
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
                      'Total Tips',
                      _tips.length.toString(),
                      Icons.lightbulb,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Featured',
                      _tips.where((t) => t.isFeatured).length.toString(),
                      Icons.star,
                      const Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Categories',
                      _tips.map((t) => t.category).toSet().length.toString(),
                      Icons.category,
                      const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),

            // Tips List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : _tips.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No eco tips created yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the + button to create your first tip',
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
                          itemCount: _tips.length,
                          itemBuilder: (context, index) {
                            return _buildTipCard(_tips[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTip,
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

  Widget _buildTipCard(EcoTipModel tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tip Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(tip.category).withOpacity(0.1),
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
                    color: _getCategoryColor(tip.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(tip.category),
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
                        tip.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(tip.category),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tip.category.toString().split('.').last.toUpperCase(),
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
                if (tip.isFeatured)
                  const Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 24,
                  ),
              ],
            ),
          ),

          // Tip Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Tip Stats
                Row(
                  children: [
                    _buildStatItem(
                      Icons.star,
                      '${tip.ecoPointsReward}',
                      'Points',
                      const Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      Icons.visibility,
                      '${tip.viewsCount}',
                      'Views',
                      const Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      Icons.favorite,
                      '${tip.likesCount}',
                      'Likes',
                      const Color(0xFFE91E63),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tags
                if (tip.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    children: tip.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleFeaturedStatus(tip),
                        icon: Icon(
                          tip.isFeatured ? Icons.star_border : Icons.star,
                        ),
                        label: Text(tip.isFeatured ? 'Unfeature' : 'Feature'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Edit tip
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit tip feature coming soon!'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          side: const BorderSide(color: Color(0xFF2196F3)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteTipDialog(tip),
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

  void _showDeleteTipDialog(EcoTipModel tip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tip'),
        content: Text(
          'Are you sure you want to delete "${tip.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteTip(tip);
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

  Color _getCategoryColor(TipCategory category) {
    switch (category) {
      case TipCategory.energy:
        return const Color(0xFFFF9800);
      case TipCategory.water:
        return const Color(0xFF2196F3);
      case TipCategory.waste:
        return const Color(0xFF795548);
      case TipCategory.transport:
        return const Color(0xFF9C27B0);
      case TipCategory.food:
        return const Color(0xFF4CAF50);
      case TipCategory.lifestyle:
        return const Color(0xFF607D8B);
      case TipCategory.home:
        return const Color(0xFF3F51B5);
      case TipCategory.garden:
        return const Color(0xFF8BC34A);
    }
  }

  IconData _getCategoryIcon(TipCategory category) {
    switch (category) {
      case TipCategory.energy:
        return Icons.electric_bolt;
      case TipCategory.water:
        return Icons.water_drop;
      case TipCategory.waste:
        return Icons.delete;
      case TipCategory.transport:
        return Icons.directions_car;
      case TipCategory.food:
        return Icons.restaurant;
      case TipCategory.lifestyle:
        return Icons.eco;
      case TipCategory.home:
        return Icons.home;
      case TipCategory.garden:
        return Icons.local_florist;
    }
  }
}

class CreateTipModal extends StatefulWidget {
  const CreateTipModal({super.key});

  @override
  State<CreateTipModal> createState() => _CreateTipModalState();
}

class _CreateTipModalState extends State<CreateTipModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _ecoPointsController = TextEditingController();
  final _tagsController = TextEditingController();
  
  TipCategory _selectedCategory = TipCategory.lifestyle;
  bool _isFeatured = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _ecoPointsController.dispose();
    _tagsController.dispose();
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
              'Create New Eco Tip',
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
                        labelText: 'Tip Title',
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
                        labelText: 'Short Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Content
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Detailed Content',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter content';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category and Points
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TipCategory>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: TipCategory.values.map((category) {
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
                          child: TextFormField(
                            controller: _ecoPointsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Eco Points',
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

                    // Tags
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: 'energy, sustainability, tips',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Featured Toggle
                    SwitchListTile(
                      title: const Text('Featured Tip'),
                      subtitle: const Text('Show this tip in featured section'),
                      value: _isFeatured,
                      onChanged: (value) {
                        setState(() {
                          _isFeatured = value;
                        });
                      },
                      activeColor: const Color(0xFF4CAF50),
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
                    onPressed: _createTip,
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

  void _createTip() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      Navigator.pop(context, {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'content': _contentController.text,
        'category': _selectedCategory,
        'ecoPointsReward': int.parse(_ecoPointsController.text),
        'isFeatured': _isFeatured,
        'tags': tags,
      });
    }
  }
} 