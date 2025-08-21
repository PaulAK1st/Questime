import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_model.dart';

class Survey {
  final String id;
  final String title;
  final String description;
  final String? bannerUrl;
  final List<Question> questions;
  final bool hasReward;
  final DateTime createdAt;
  final String ownerId;
  final String ownerName;
  final int responseCount;
  final bool isPublic;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    this.bannerUrl,
    required this.questions,
    this.hasReward = false,
    required this.createdAt,
    required this.ownerId,
    this.ownerName = 'Anonymous',
    this.responseCount = 0,
    this.isPublic = true,
  });

  // Copy with method for easier updates
  Survey copyWith({
    String? id,
    String? title,
    String? description,
    String? bannerUrl,
    List<Question>? questions,
    bool? hasReward,
    DateTime? createdAt,
    String? ownerId,
    String? ownerName,
    int? responseCount,
    bool? isPublic,
  }) {
    return Survey(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      questions: questions ?? this.questions,
      hasReward: hasReward ?? this.hasReward,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      responseCount: responseCount ?? this.responseCount,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  // Convert Survey to Map for Firestore
Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'bannerUrl': bannerUrl,
      'questions': questions.map((q) => q.toMap()).toList(),
      'hasReward': hasReward,
      'createdAt': createdAt,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'responseCount': responseCount,
      'isPublic': isPublic,
    };
  }

  // Convert Survey to JSON
Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'bannerUrl': bannerUrl,
      'questions': questions.map((q) => q.toJson()).toList(),
      'hasReward': hasReward,
      'createdAt': createdAt.toIso8601String(),
      'ownerId': ownerId,
      'ownerName': ownerName,
      'responseCount': responseCount,
      'isPublic': isPublic,
    };
  }

  // Create Survey from Firestore
  factory Survey.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Survey(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      bannerUrl: data['bannerUrl'],
      questions: (data['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList() ?? [],
      hasReward: data['hasReward'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? 'Anonymous',
      responseCount: data['responseCount'] ?? 0,
      isPublic: data['isPublic'] ?? true,
    );
  }

  // Create Survey from Map
  factory Survey.fromMap(Map<String, dynamic> map) {
    return Survey(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      bannerUrl: map['bannerUrl'],
      questions: (map['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList() ?? [],
      hasReward: map['hasReward'] ?? false,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] is String
              ? DateTime.parse(map['createdAt'])
              : map['createdAt'] ?? DateTime.now(),
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? 'Anonymous',
      responseCount: map['responseCount'] ?? 0,
      isPublic: map['isPublic'] ?? true,
    );
  }

  // Create Survey from JSON
  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      bannerUrl: json['bannerUrl'],
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList() ?? [],
      hasReward: json['hasReward'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? 'Anonymous',
      responseCount: json['responseCount'] ?? 0,
      isPublic: json['isPublic'] ?? true,
    );
  }

  // Helper methods
  bool get isEmpty => questions.isEmpty;
  bool get isNotEmpty => questions.isNotEmpty;
  int get questionCount => questions.length;
  
  // Check survey by specific user
  bool isOwnedBy(String userId) => ownerId == userId;
  
  // Get questions by type
  List<Question> getQuestionsByType(QuestionType type) {
    return questions.where((q) => q.type == type).toList();
  }
  
  // Get required questions
  List<Question> get requiredQuestions {
    return questions.where((q) => q.isRequired).toList();
  }
  
  // Check if survey has any required questions
  bool get hasRequiredQuestions => requiredQuestions.isNotEmpty;
  
  @override
  String toString() {
    return 'Survey(id: $id, title: $title, questionCount: $questionCount, responseCount: $responseCount)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Survey && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
