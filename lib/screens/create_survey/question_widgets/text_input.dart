import 'package:flutter/material.dart';
import '../../../models/question_model.dart';

class TextInputWidget extends StatelessWidget {
  final Question question;
  final Function(Question)? onUpdate;
  final bool isBuilder;

  const TextInputWidget({
    super.key,
    required this.question,
    this.onUpdate,
    this.isBuilder = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isBuilder) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Respondent will type their answer here...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            enabled: false,
            maxLines: question.settings['multiline'] == true ? 3 : 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: question.settings['multiline'] == true,
                onChanged: (value) {
                  if (onUpdate != null) {
                    final settings = Map<String, dynamic>.from(question.settings);
                    settings['multiline'] = value;
                    onUpdate!(question.copyWith(settings: settings));
                  }
                },
              ),
              const Text('Allow multiple lines'),
            ],
          ),
        ],
      );
    }

    return TextField(
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        border: const OutlineInputBorder(),
      ),
      maxLines: question.settings['multiline'] == true ? 3 : 1,
    );
  }
}
