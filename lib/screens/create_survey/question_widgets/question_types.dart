import 'package:flutter/material.dart';
import '../../../models/question_model.dart';
import 'bar_chart_widget.dart';
import 'file_upload_widget.dart';
import 'multiple_choice.dart';
import 'percentage_scale.dart';
import 'ranking_widget.dart';
import 'text_input.dart';

class QuestionWidgetFactory {
  static Widget build({
    required QuestionType type,
    required Map<String, dynamic> data,
    required Function(dynamic) onAnswer,
  }) {
    final question = Question(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: data['text'] ?? '',
      type: type,
      order: data['order'] ?? 0,
      settings: data['settings'] ?? {},
      isRequired: data['isRequired'] ?? false,
    );

    switch (type) {
      case QuestionType.percentageScale:
        return PercentageScaleWidget(
          question: question.copyWith(
            settings: {
              'min': data['min'] ?? 0,
              'max': data['max'] ?? 100,
              'step': data['step'] ?? 1,
              ...question.settings,
            },
          ),
          onUpdate: (updatedQuestion) {
            onAnswer(updatedQuestion.settings);
          },
          isBuilder: data['isBuilder'] ?? false,
        );

      case QuestionType.textInput:
        return TextInputWidget(
          question: question.copyWith(
            settings: {
              'multiline': data['multiline'] ?? true,
              ...question.settings,
            },
          ),
          onUpdate: (updatedQuestion) {
            onAnswer(updatedQuestion.settings);
          },
          isBuilder: data['isBuilder'] ?? false,
        );
            case QuestionType.starRating:
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Star Rating Widget'),
              Text('Max Stars: ${data['maxStars'] ?? 5}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  data['maxStars'] ?? 5,
                  (index) => Icon(
                    Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        );
        
      case QuestionType.ranking:
        return RankingWidget(
          question: question.copyWith(
            settings: {
              'items': List<String>.from(data['items'] ?? ['Item 1', 'Item 2', 'Item 3']),
              ...question.settings,
            },
          ),
          onUpdate: (updatedQuestion) {
            onAnswer(updatedQuestion.settings);
          },
          isBuilder: data['isBuilder'] ?? false,
        );

      case QuestionType.barChart:
        return BarChartWidget(
          question: question.copyWith(
            settings: {
              'choices': List<String>.from(data['choices'] ?? ['Choice 1', 'Choice 2']),
              'percentages': List<double>.from(data['percentages'] ?? [50.0, 50.0]),
              'title': data['title'] ?? 'Chart Title',
              ...question.settings,
            },
          ),
          onUpdate: (updatedQuestion) {
            onAnswer(updatedQuestion.settings);
          },
          isBuilder: data['isBuilder'] ?? false,
        );

      case QuestionType.multipleChoice:
        return MultipleChoiceWidget(
          question: question.copyWith(
            settings: {
              'options': List<String>.from(data['choices'] ?? data['options'] ?? ['Option 1', 'Option 2', 'Option 3']),
              'allowMultiple': data['allowMultiple'] ?? false,
              'allowOther': data['allowOther'] ?? false,
              ...question.settings,
            },
          ),
          onUpdate: (updatedQuestion) {
            onAnswer(updatedQuestion.settings);
          },
          isBuilder: data['isBuilder'] ?? false,
        );

      case QuestionType.fileUpload:
        return FileUploadWidget(
          question: question.copyWith(
            settings: {
              'allowMultiple': data['allowMultiple'] ?? false,
              'acceptedTypes': data['acceptedTypes'] ?? '',
              'maxFileSize': data['maxFileSize'] ?? 10, // MB
              ...question.settings,
            },
          ),
          onUpdate: (updatedQuestion) {
            onAnswer(updatedQuestion.settings);
          },
          isBuilder: data['isBuilder'] ?? false,
        );
    }
  }
}