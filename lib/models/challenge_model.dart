
enum ChallengeDifficulty { easy, medium, hard }
enum ChallengeCategory { energy, water, waste, transport, food, lifestyle }

class ChallengeModel {
  String? id;
  String title;
  String description;
  ChallengeCategory category;
  ChallengeDifficulty difficulty;
  int ecoPointsReward;
  int carbonFootprintReduction;
  String? imageUrl;
  DateTime startDate;
  DateTime endDate;
  bool isActive;
  List<String> requirements;
  List<String> tips;
  int participantsCount;
  DateTime? createdAt;
  String? createdBy;

  ChallengeModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.ecoPointsReward,
    required this.carbonFootprintReduction,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.requirements = const [],
    this.tips = const [],
    this.participantsCount = 0,
    this.createdAt,
    this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "category": category.toString().split('.').last,
      "difficulty": difficulty.toString().split('.').last,
      "ecoPointsReward": ecoPointsReward,
      "carbonFootprintReduction": carbonFootprintReduction,
      "imageUrl": imageUrl,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "isActive": isActive,
      "requirements": requirements,
      "tips": tips,
      "participantsCount": participantsCount,
      "createdAt": createdAt?.toIso8601String(),
      "createdBy": createdBy,
    };
  }

  factory ChallengeModel.fromMap(Map<String, dynamic> map) {
    return ChallengeModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: ChallengeCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => ChallengeCategory.lifestyle,
      ),
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == map['difficulty'],
        orElse: () => ChallengeDifficulty.easy,
      ),
      ecoPointsReward: map['ecoPointsReward'] ?? 0,
      carbonFootprintReduction: map['carbonFootprintReduction'] ?? 0,
      imageUrl: map['imageUrl'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isActive: map['isActive'] ?? true,
      requirements: List<String>.from(map['requirements'] ?? []),
      tips: List<String>.from(map['tips'] ?? []),
      participantsCount: map['participantsCount'] ?? 0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : null,
      createdBy: map['createdBy'],
    );
  }
} 