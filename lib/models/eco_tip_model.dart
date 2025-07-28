
enum TipCategory { energy, water, waste, transport, food, lifestyle, home, garden }

class EcoTipModel {
  String? id;
  String title;
  String description;
  String content;
  TipCategory category;
  String? imageUrl;
  int ecoPointsReward;
  bool isFeatured;
  DateTime? createdAt;
  String? createdBy;
  int viewsCount;
  int likesCount;
  List<String> tags;
  String? source;
  String? sourceUrl;

  EcoTipModel({
    this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    this.imageUrl,
    this.ecoPointsReward = 0,
    this.isFeatured = false,
    this.createdAt,
    this.createdBy,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.tags = const [],
    this.source,
    this.sourceUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "content": content,
      "category": category.toString().split('.').last,
      "imageUrl": imageUrl,
      "ecoPointsReward": ecoPointsReward,
      "isFeatured": isFeatured,
      "createdAt": createdAt?.toIso8601String(),
      "createdBy": createdBy,
      "viewsCount": viewsCount,
      "likesCount": likesCount,
      "tags": tags,
      "source": source,
      "sourceUrl": sourceUrl,
    };
  }

  factory EcoTipModel.fromMap(Map<String, dynamic> map) {
    return EcoTipModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      category: TipCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => TipCategory.lifestyle,
      ),
      imageUrl: map['imageUrl'],
      ecoPointsReward: map['ecoPointsReward'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : null,
      createdBy: map['createdBy'],
      viewsCount: map['viewsCount'] ?? 0,
      likesCount: map['likesCount'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      source: map['source'],
      sourceUrl: map['sourceUrl'],
    );
  }
} 