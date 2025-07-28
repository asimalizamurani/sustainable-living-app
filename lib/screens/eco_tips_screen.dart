import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/eco_tip_model.dart';

class EcoTipsScreen extends StatefulWidget {
  const EcoTipsScreen({super.key});

  @override
  State<EcoTipsScreen> createState() => _EcoTipsScreenState();
}

class _EcoTipsScreenState extends State<EcoTipsScreen> {
  List<EcoTipModel> _tips = [];
  List<EcoTipModel> _featuredTips = [];
  bool _isLoading = true;
  TipCategory _selectedCategory = TipCategory.lifestyle;
  String _searchQuery = '';

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

      _featuredTips = _tips.where((tip) => tip.isFeatured).toList();

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

  List<EcoTipModel> get _filteredTips {
    List<EcoTipModel> filtered = _tips;

    // Filter by category
    if (_selectedCategory != TipCategory.lifestyle) {
      filtered = filtered.where((tip) => tip.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((tip) =>
          tip.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tip.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tip.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tip.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eco Tips & Advice',
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
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search eco tips...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Category Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TipCategory.values.map((category) {
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

            const SizedBox(height: 16),

            // Featured Tips Section
            if (_featuredTips.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Color(0xFFFFD700),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Featured Tips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _featuredTips.length,
                  itemBuilder: (context, index) {
                    return _buildFeaturedTipCard(_featuredTips[index]);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // All Tips Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_filteredTips.length} tips',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tips List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : _filteredTips.isEmpty
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
                                'No tips found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTips.length,
                          itemBuilder: (context, index) {
                            return _buildTipCard(_filteredTips[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedTipCard(EcoTipModel tip) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tip Image or Icon
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: _getCategoryColor(tip.category).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  if (tip.imageUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        tip.imageUrl!,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              _getCategoryIcon(tip.category),
                              size: 40,
                              color: _getCategoryColor(tip.category),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Center(
                      child: Icon(
                        _getCategoryIcon(tip.category),
                        size: 40,
                        color: _getCategoryColor(tip.category),
                      ),
                    ),
                  if (tip.isFeatured)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'FEATURED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Tip Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: const Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tip.ecoPointsReward} points',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.visibility,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tip.viewsCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getCategoryColor(tip.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(tip.category),
            color: _getCategoryColor(tip.category),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                tip.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (tip.isFeatured)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  size: 12,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              tip.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 14,
                  color: const Color(0xFFFFD700),
                ),
                const SizedBox(width: 4),
                Text(
                  '${tip.ecoPointsReward} points',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.visibility,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${tip.viewsCount}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.favorite,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${tip.likesCount}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            if (tip.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: tip.tags.take(3).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
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
            ],
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          _showTipDetail(tip);
        },
      ),
    );
  }

  void _showTipDetail(EcoTipModel tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(tip.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(tip.category),
                            color: _getCategoryColor(tip.category),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tip.category.toString().split('.').last.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getCategoryColor(tip.category),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Text(
                      tip.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Content
                    Text(
                      tip.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats
                    Row(
                      children: [
                        _buildDetailStat(
                          Icons.star,
                          '${tip.ecoPointsReward}',
                          'Points',
                        ),
                        const SizedBox(width: 24),
                        _buildDetailStat(
                          Icons.visibility,
                          '${tip.viewsCount}',
                          'Views',
                        ),
                        const SizedBox(width: 24),
                        _buildDetailStat(
                          Icons.favorite,
                          '${tip.likesCount}',
                          'Likes',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement like functionality
                      },
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Like'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4CAF50),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement share functionality
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  Widget _buildDetailStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
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