import 'package:flutter/material.dart';

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final Map<String, dynamic> settings;
  final bool isRequired;
  final int order;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.settings = const {},
    this.isRequired = false,
    required this.order,
  });

  Question copyWith({
    String? id,
    String? text,
    QuestionType? type,
    Map<String, dynamic>? settings,
    bool? isRequired,
    int? order,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      settings: settings ?? this.settings,
      isRequired: isRequired ?? this.isRequired,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString(),
      'settings': settings,
      'isRequired': isRequired,
      'order': order,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: QuestionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      isRequired: json['isRequired'] ?? false,
      order: json['order'] ?? 0,
    );
  }

  // Convert question to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last, 
      'settings': settings,
      'isRequired': isRequired,
      'order': order,
    };
  }

  // Create Question from Map
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      type: _parseQuestionType(map['type']),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      isRequired: map['isRequired'] ?? false,
      order: map['order'] ?? 0,
    );
  }

  // Helper method to parse question type
  static QuestionType _parseQuestionType(String? typeString) {
    switch (typeString) {
      case 'textInput':
        return QuestionType.textInput;
      case 'multipleChoice':
        return QuestionType.multipleChoice;
      case 'percentageScale':
        return QuestionType.percentageScale;
      case 'ranking':
        return QuestionType.ranking;
      case 'barChart':
        return QuestionType.barChart;
      case 'fileUpload':
        return QuestionType.fileUpload;
      case 'starRating':
        return QuestionType.starRating;
      default:
        return QuestionType.textInput; 
    }
  }

  // Helper getters to access common settings
  List<String> get options => List<String>.from(settings['options'] ?? []);
  int? get maxLength => settings['maxLength'];
  double? get minValue => settings['minValue']?.toDouble();
  double? get maxValue => settings['maxValue']?.toDouble();
  bool get allowMultiple => settings['allowMultiple'] ?? false;
}

enum QuestionType {
  textInput,
  multipleChoice,
  percentageScale,
  ranking,
  barChart,
  fileUpload,
  starRating,
}

extension QuestionTypeExtension on QuestionType {
  String get displayName {
    switch (this) {
      case QuestionType.textInput:
        return 'Text Input';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.percentageScale:
        return 'Percentage Scale';
      case QuestionType.ranking:
        return 'Ranking';
      case QuestionType.barChart:
        return 'Bar Chart';
      case QuestionType.fileUpload:
        return 'File Upload';
      case QuestionType.starRating:
        return 'Star Rating';
    }
  }

  IconData get icon {
    switch (this) {
      case QuestionType.textInput:
        return Icons.text_fields;
      case QuestionType.multipleChoice:
        return Icons.radio_button_checked;
      case QuestionType.percentageScale:
        return Icons.linear_scale;
      case QuestionType.ranking:
        return Icons.format_list_numbered;
      case QuestionType.barChart:
        return Icons.bar_chart;
      case QuestionType.fileUpload:
        return Icons.file_upload;
      case QuestionType.starRating:
        return Icons.star_rate;
    }
  }

  Color get color {
    switch (this) {
      case QuestionType.textInput:
        return Colors.blue;
      case QuestionType.multipleChoice:
        return Colors.green;
      case QuestionType.percentageScale:
        return Colors.orange;
      case QuestionType.ranking:
        return Colors.purple;
      case QuestionType.barChart:
        return Colors.teal;
      case QuestionType.fileUpload:
        return Colors.red;
      case QuestionType.starRating:
        return Colors.amber;
    }
  }
}
