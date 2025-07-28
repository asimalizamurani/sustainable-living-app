import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      if (_authService.currentUser != null) {
        _currentUser = await _authService.getUserById(_authService.currentUser!.uid);
        
        if (_currentUser != null) {
          _nameController.text = _currentUser!.name ?? '';
          _phoneController.text = _currentUser!.phoneNumber ?? '';
          _addressController.text = _currentUser!.address ?? '';
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        // TODO: Upload image to Firebase Storage and update user profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_authService.currentUser != null) {
        await _authService.updateUserProfile(_authService.currentUser!.uid, {
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Image Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: const Color(0xFF4CAF50),
                                    backgroundImage: _currentUser?.profileImage != null
                                        ? NetworkImage(_currentUser!.profileImage!)
                                        : null,
                                    child: _currentUser?.profileImage == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Change Photo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Personal Information
                      Card(
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
                                'Personal Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Name Field
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  if (value.length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Phone Field
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
                                      return 'Please enter a valid phone number';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Address Field
                              TextFormField(
                                controller: _addressController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  prefixIcon: Icon(Icons.location_on),
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Preferences Section
                      Card(
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
                                'Preferences',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Notifications Toggle
                              SwitchListTile(
                                title: const Text('Enable Notifications'),
                                subtitle: const Text('Receive updates about challenges and tips'),
                                value: _currentUser?.notificationsEnabled ?? true,
                                onChanged: (value) {
                                  setState(() {
                                    _currentUser = _currentUser?.copyWith(
                                      notificationsEnabled: value,
                                    );
                                  });
                                },
                                activeColor: const Color(0xFF4CAF50),
                              ),

                              const Divider(),

                              // Language Selection
                              ListTile(
                                title: const Text('Language'),
                                subtitle: Text(_currentUser?.preferredLanguage ?? 'English'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  _showLanguageDialog();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
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
              ),
            ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'English',
                groupValue: _currentUser?.preferredLanguage ?? 'English',
                onChanged: (value) {
                  setState(() {
                    _currentUser = _currentUser?.copyWith(
                      preferredLanguage: value,
                    );
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Spanish'),
              leading: Radio<String>(
                value: 'Spanish',
                groupValue: _currentUser?.preferredLanguage ?? 'English',
                onChanged: (value) {
                  setState(() {
                    _currentUser = _currentUser?.copyWith(
                      preferredLanguage: value,
                    );
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('French'),
              leading: Radio<String>(
                value: 'French',
                groupValue: _currentUser?.preferredLanguage ?? 'English',
                onChanged: (value) {
                  setState(() {
                    _currentUser = _currentUser?.copyWith(
                      preferredLanguage: value,
                    );
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }
} 