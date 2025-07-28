import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/carbon_tracker_model.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class CarbonTrackerScreen extends StatefulWidget {
  const CarbonTrackerScreen({super.key});

  @override
  State<CarbonTrackerScreen> createState() => _CarbonTrackerScreenState();
}

class _CarbonTrackerScreenState extends State<CarbonTrackerScreen> {
  final AuthService _authService = AuthService();
  List<CarbonTrackerModel> _activities = [];
  bool _isLoading = true;
  ActivityType _selectedFilter = ActivityType.lifestyle;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_authService.currentUser != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('carbon_tracker')
            .where('userId', isEqualTo: _authService.currentUser!.uid)
            .orderBy('date', descending: true)
            .get();

        _activities = snapshot.docs
            .map((doc) => CarbonTrackerModel.fromMap(doc.data()))
            .toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading activities: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addActivity() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddActivityModal(),
    );

    if (result != null) {
      try {
        final activity = CarbonTrackerModel(
          userId: _authService.currentUser!.uid,
          activityType: result['activityType'],
          activityName: result['activityName'],
          carbonFootprint: result['carbonFootprint'],
          description: result['description'],
          date: result['date'],
          location: result['location'],
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('carbon_tracker')
            .add(activity.toMap());

        _loadActivities();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity added successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<CarbonTrackerModel> get _filteredActivities {
    return _activities.where((activity) {
      final sameDate = activity.date.year == _selectedDate.year &&
          activity.date.month == _selectedDate.month &&
          activity.date.day == _selectedDate.day;
      
      final sameType = _selectedFilter == ActivityType.lifestyle ||
          activity.activityType == _selectedFilter;

      return sameDate && sameType;
    }).toList();
  }

  double get _totalCarbonFootprint {
    return _filteredActivities.fold(0, (sum, activity) => sum + activity.carbonFootprint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carbon Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _selectDate,
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
            stops: [0.0, 0.2, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Summary Card
            Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Today\'s Carbon Footprint',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryItem(
                              'Total CO₂',
                              '${_totalCarbonFootprint.toStringAsFixed(2)} kg',
                              Icons.eco,
                              const Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryItem(
                              'Activities',
                              '${_filteredActivities.length}',
                              Icons.list,
                              const Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('ALL'),
                      selected: _selectedFilter == ActivityType.lifestyle,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = ActivityType.lifestyle;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF4CAF50),
                      checkmarkColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    ...ActivityType.values.where((type) => type != ActivityType.lifestyle).map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            type.toString().split('.').last.toUpperCase(),
                          ),
                          selected: _selectedFilter == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = type;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF4CAF50),
                          checkmarkColor: Colors.white,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Activities List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : _filteredActivities.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.track_changes_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No activities for this day',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the + button to add an activity',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredActivities.length,
                          itemBuilder: (context, index) {
                            return _buildActivityCard(_filteredActivities[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
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
            fontSize: 20,
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
        ),
      ],
    );
  }

  Widget _buildActivityCard(CarbonTrackerModel activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getActivityColor(activity.activityType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getActivityIcon(activity.activityType),
            color: _getActivityColor(activity.activityType),
            size: 24,
          ),
        ),
        title: Text(
          activity.activityName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (activity.description != null) ...[
              Text(
                activity.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(activity.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (activity.location != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    activity.location!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${activity.carbonFootprint.toStringAsFixed(2)} kg',
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        onTap: () {
          _showActivityDetail(activity);
        },
      ),
    );
  }

  void _showActivityDetail(CarbonTrackerModel activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getActivityColor(activity.activityType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getActivityIcon(activity.activityType),
                            color: _getActivityColor(activity.activityType),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.activityName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activity.activityType.toString().split('.').last.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getActivityColor(activity.activityType),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Carbon Footprint
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.eco,
                            color: Color(0xFF4CAF50),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Carbon Footprint',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${activity.carbonFootprint.toStringAsFixed(2)} kg CO₂',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Details
                    if (activity.description != null) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Date and Time
                    const Text(
                      'Date & Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(activity.date),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(activity.date),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    if (activity.location != null) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.location!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.transport:
        return const Color(0xFF2196F3);
      case ActivityType.energy:
        return const Color(0xFFFF9800);
      case ActivityType.food:
        return const Color(0xFF4CAF50);
      case ActivityType.waste:
        return const Color(0xFF795548);
      case ActivityType.water:
        return const Color(0xFF00BCD4);
      case ActivityType.shopping:
        return const Color(0xFF9C27B0);
      case ActivityType.lifestyle:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.transport:
        return Icons.directions_car;
      case ActivityType.energy:
        return Icons.electric_bolt;
      case ActivityType.food:
        return Icons.restaurant;
      case ActivityType.waste:
        return Icons.delete;
      case ActivityType.water:
        return Icons.water_drop;
      case ActivityType.shopping:
        return Icons.shopping_cart;
      case ActivityType.lifestyle:
        return Icons.eco;
    }
  }
}

class AddActivityModal extends StatefulWidget {
  const AddActivityModal({super.key});

  @override
  State<AddActivityModal> createState() => _AddActivityModalState();
}

class _AddActivityModalState extends State<AddActivityModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _carbonController = TextEditingController();
  
  ActivityType _selectedType = ActivityType.lifestyle;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _carbonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          
          // Header
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Add Activity',
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
                    // Activity Type
                    DropdownButtonFormField<ActivityType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Activity Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ActivityType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.toString().split('.').last.toUpperCase(),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Activity Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Activity Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter activity name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Carbon Footprint
                    TextFormField(
                      controller: _carbonController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Carbon Footprint (kg CO₂)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter carbon footprint';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date and Time
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Date'),
                            subtitle: Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _selectDate,
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Time'),
                            subtitle: Text(_selectedTime.format(context)),
                            trailing: const Icon(Icons.access_time),
                            onTap: _selectTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (Optional)',
                        border: OutlineInputBorder(),
                      ),
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
                    onPressed: _saveActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      Navigator.pop(context, {
        'activityType': _selectedType,
        'activityName': _nameController.text,
        'carbonFootprint': double.parse(_carbonController.text),
        'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
        'date': dateTime,
        'location': _locationController.text.isEmpty ? null : _locationController.text,
      });
    }
  }
} 