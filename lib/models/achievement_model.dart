
enum AchievementType { milestone, streak, challenge, community, special }

class AchievementModel {
  String? id;
  String title;
  String description;
  AchievementType type;
  String? iconUrl;
  int ecoPointsReward;
  bool isUnlocked;
  DateTime? unlockedAt;
  String? unlockedBy;
  Map<String, dynamic>? criteria;
  int rarity; // 1-5 stars
  String? category;

  AchievementModel({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.iconUrl,
    required this.ecoPointsReward,
    this.isUnlocked = false,
    this.unlockedAt,
    this.unlockedBy,
    this.criteria,
    this.rarity = 1,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "type": type.toString().split('.').last,
      "iconUrl": iconUrl,
      "ecoPointsReward": ecoPointsReward,
      "isUnlocked": isUnlocked,
      "unlockedAt": unlockedAt?.toIso8601String(),
      "unlockedBy": unlockedBy,
      "criteria": criteria,
      "rarity": rarity,
      "category": category,
    };
  }

  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    return AchievementModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => AchievementType.milestone,
      ),
      iconUrl: map['iconUrl'],
      ecoPointsReward: map['ecoPointsReward'] ?? 0,
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null 
          ? DateTime.parse(map['unlockedAt']) 
          : null,
      unlockedBy: map['unlockedBy'],
      criteria: map['criteria'],
      rarity: map['rarity'] ?? 1,
      category: map['category'],
    );
  }
} 