
enum ActivityType { 
  transport, 
  energy, 
  food, 
  waste, 
  water, 
  shopping, 
  lifestyle 
}

class CarbonTrackerModel {
  String? id;
  String userId;
  ActivityType activityType;
  String activityName;
  double carbonFootprint;
  String? description;
  DateTime date;
  String? location;
  Map<String, dynamic>? activityData;
  bool isVerified;
  DateTime? createdAt;
  DateTime? updatedAt;

  CarbonTrackerModel({
    this.id,
    required this.userId,
    required this.activityType,
    required this.activityName,
    required this.carbonFootprint,
    this.description,
    required this.date,
    this.location,
    this.activityData,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "activityType": activityType.toString().split('.').last,
      "activityName": activityName,
      "carbonFootprint": carbonFootprint,
      "description": description,
      "date": date.toIso8601String(),
      "location": location,
      "activityData": activityData,
      "isVerified": isVerified,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }

  factory CarbonTrackerModel.fromMap(Map<String, dynamic> map) {
    return CarbonTrackerModel(
      id: map['id'],
      userId: map['userId'] ?? '',
      activityType: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == map['activityType'],
        orElse: () => ActivityType.lifestyle,
      ),
      activityName: map['activityName'] ?? '',
      carbonFootprint: (map['carbonFootprint'] ?? 0).toDouble(),
      description: map['description'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      activityData: map['activityData'],
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }
} 