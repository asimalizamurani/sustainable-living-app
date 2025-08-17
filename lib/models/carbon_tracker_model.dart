import 'package:cloud_firestore/cloud_firestore.dart';

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

  CarbonTrackerModel copyWith({
    String? id,
    String? userId,
    ActivityType? activityType,
    String? activityName,
    double? carbonFootprint,
    String? description,
    DateTime? date,
    String? location,
    Map<String, dynamic>? activityData,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CarbonTrackerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      activityName: activityName ?? this.activityName,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      activityData: activityData ?? this.activityData,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "activityType": activityType.toString().split('.').last,
      "activityName": activityName,
      "carbonFootprint": carbonFootprint,
      "description": description,
      "date": Timestamp.fromDate(date),
      "location": location,
      "activityData": activityData,
      "isVerified": isVerified,
      "createdAt": createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
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
      date: (map['date'] as Timestamp).toDate(),
      location: map['location'],
      activityData: map['activityData'],
      isVerified: map['isVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
} 