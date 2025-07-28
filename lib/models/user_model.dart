
enum UserRole { user, admin }

class UserModel {
  String? id;
  String? name;
  String? email;
  String? password;
  UserRole role;
  String? profileImage;
  String? phoneNumber;
  String? address;
  DateTime? dateOfBirth;
  DateTime? createdAt;
  DateTime? lastLoginAt;
  
  // Sustainability metrics
  int carbonFootprint;
  int ecoPoints;
  int challengesCompleted;
  List<String> achievements;
  List<String> interests;
  
  // Preferences
  bool notificationsEnabled;
  String? preferredLanguage;
  String? timezone;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.user,
    this.profileImage,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
    this.createdAt,
    this.lastLoginAt,
    this.carbonFootprint = 0,
    this.ecoPoints = 0,
    this.challengesCompleted = 0,
    this.achievements = const [],
    this.interests = const [],
    this.notificationsEnabled = true,
    this.preferredLanguage,
    this.timezone,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "password": password,
      "role": role.toString().split('.').last,
      "profileImage": profileImage,
      "phoneNumber": phoneNumber,
      "address": address,
      "dateOfBirth": dateOfBirth?.toIso8601String(),
      "createdAt": createdAt?.toIso8601String(),
      "lastLoginAt": lastLoginAt?.toIso8601String(),
      "carbonFootprint": carbonFootprint,
      "ecoPoints": ecoPoints,
      "challengesCompleted": challengesCompleted,
      "achievements": achievements,
      "interests": interests,
      "notificationsEnabled": notificationsEnabled,
      "preferredLanguage": preferredLanguage,
      "timezone": timezone,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.user,
      profileImage: map['profileImage'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.parse(map['dateOfBirth']) 
          : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : null,
      lastLoginAt: map['lastLoginAt'] != null 
          ? DateTime.parse(map['lastLoginAt']) 
          : null,
      carbonFootprint: map['carbonFootprint'] ?? 0,
      ecoPoints: map['ecoPoints'] ?? 0,
      challengesCompleted: map['challengesCompleted'] ?? 0,
      achievements: List<String>.from(map['achievements'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      preferredLanguage: map['preferredLanguage'],
      timezone: map['timezone'],
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? profileImage,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? carbonFootprint,
    int? ecoPoints,
    int? challengesCompleted,
    List<String>? achievements,
    List<String>? interests,
    bool? notificationsEnabled,
    String? preferredLanguage,
    String? timezone,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      challengesCompleted: challengesCompleted ?? this.challengesCompleted,
      achievements: achievements ?? this.achievements,
      interests: interests ?? this.interests,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
    );
  }
}