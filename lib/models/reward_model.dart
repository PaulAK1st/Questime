import 'package:cloud_firestore/cloud_firestore.dart';

class RewardModel {
  final String id;
  final String? businessId;
  final String title;
  final String description;
  final int pointsRequired;
  final String imageUrl;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime createdAt;
  final int redeemedCount;
  final String type; 
  final String? userId;
  final int? points;
  final String? reason;
  final String? surveyId;
  final DateTime? awardedAt;
  final String? rewardId;
  final String? status;

  RewardModel({
    required this.id,
    this.businessId,
    required this.title,
    required this.description,
    this.pointsRequired = 0,
    this.imageUrl = '',
    this.expiryDate,
    this.isActive = true,
    required this.createdAt,
    this.redeemedCount = 0,
    this.type = 'business_reward',
    this.userId,
    this.points,
    this.reason,
    this.surveyId,
    this.awardedAt,
    this.rewardId,
    this.status,
  });

  // RewardModel from Firestore
  factory RewardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardModel.fromJson({...data, 'id': doc.id});
  }

  // RewardModel from JSON/Map
  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] ?? '',
      businessId: json['businessId'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pointsRequired: json['pointsRequired'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      expiryDate: json['expiryDate'] != null
          ? (json['expiryDate'] as Timestamp).toDate()
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      redeemedCount: json['redeemedCount'] ?? 0,
      type: json['type'] ?? 'business_reward',
      userId: json['userId'],
      points: json['points'],
      reason: json['reason'],
      surveyId: json['surveyId'],
      awardedAt: json['awardedAt'] != null
          ? (json['awardedAt'] as Timestamp).toDate()
          : null,
      rewardId: json['rewardId'],
      status: json['status'],
    );
  }

  // RewardModel Map for Firestore
Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'redeemedCount': redeemedCount,
      'type': type,
    };

    if (businessId != null) data['businessId'] = businessId;
    if (expiryDate != null) data['expiryDate'] = Timestamp.fromDate(expiryDate!);
    if (userId != null) data['userId'] = userId;
    if (points != null) data['points'] = points;
    if (reason != null) data['reason'] = reason;
    if (surveyId != null) data['surveyId'] = surveyId;
    if (awardedAt != null) data['awardedAt'] = Timestamp.fromDate(awardedAt!);
    if (rewardId != null) data['rewardId'] = rewardId;
    if (status != null) data['status'] = status;

    return data;
  }

  // Create copy and update
  RewardModel copyWith({
    String? id,
    String? businessId,
    String? title,
    String? description,
    int? pointsRequired,
    String? imageUrl,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    int? redeemedCount,
    String? type,
    String? userId,
    int? points,
    String? reason,
    String? surveyId,
    DateTime? awardedAt,
    String? rewardId,
    String? status,
  }) {
    return RewardModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      imageUrl: imageUrl ?? this.imageUrl,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      redeemedCount: redeemedCount ?? this.redeemedCount,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      reason: reason ?? this.reason,
      surveyId: surveyId ?? this.surveyId,
      awardedAt: awardedAt ?? this.awardedAt,
      rewardId: rewardId ?? this.rewardId,
      status: status ?? this.status,
    );
  }

  // Check expired reward
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  // Check redeemable reward
  bool get isAvailable => isActive && !isExpired;

  // Get formatted expiry date
  String get formattedExpiryDate {
    if (expiryDate == null) return 'No expiry';
    final now = DateTime.now();
    final difference = expiryDate!.difference(now);
    
    if (difference.isNegative) return 'Expired';
    if (difference.inDays > 0) return '${difference.inDays} days left';
    if (difference.inHours > 0) return '${difference.inHours} hours left';
    return '${difference.inMinutes} minutes left';
  }

  // Get reward type display name
  String get typeDisplayName {
    switch (type) {
      case 'earned':
        return 'Points Earned';
      case 'redeemed':
        return 'Reward Redeemed';
      default:
        return 'Reward';
    }
  }


  // Get points display 
  String get pointsDisplay {
    if (points == null) return '';
    return points! >= 0 ? '+$points' : '$points';
  }

  @override
  String toString() {
    return 'RewardModel(id: $id, title: $title, points: $points, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RewardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
