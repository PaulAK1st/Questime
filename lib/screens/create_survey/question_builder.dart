import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../utilities/constants.dart';
import '../../screens/create_survey/question_widgets/text_input.dart';
import '../../screens/create_survey/question_widgets/multiple_choice.dart';
import '../../screens/create_survey/question_widgets/percentage_scale.dart';
import '../../screens/create_survey/question_widgets/ranking_widget.dart';
import '../../screens/create_survey/question_widgets/bar_chart_widget.dart';
import 'question_widgets/file_upload_widget.dart';
import 'question_widgets/star_rating.dart';
import 'package:dotted_border/dotted_border.dart';

class QuestionBuilder extends StatelessWidget {
  final List<Question> questions;
  final Function(QuestionType) onQuestionAdded;
  final Function(int, Question) onQuestionUpdated;
  final Function(int) onQuestionDeleted;
  final Function(int, int) onQuestionsReordered;
  final Function(int)? onMoveQuestionUp;    
  final Function(int)? onMoveQuestionDown; 

  const QuestionBuilder({
    super.key,
    required this.questions,
    required this.onQuestionAdded,
    required this.onQuestionUpdated,
    required this.onQuestionDeleted,
    required this.onQuestionsReordered,
    this.onMoveQuestionUp,  
    this.onMoveQuestionDown, required Null Function(QuestionType type) onDropAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.quiz, color: AppConstants.primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Survey Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const Spacer(),
            Text(
              '${questions.length} questions',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Questions List
        if (questions.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            onReorder: onQuestionsReordered,
            itemBuilder: (context, index) {
              final question = questions[index];
              return _buildQuestionCard(context, question, index);
            },
          ),
        
        // Drop Zone
      _buildDropZone(),
      ],
    );
  }

Widget _buildQuestionCard(BuildContext context, Question question, int index) {
  return Card(
    key: ValueKey(question.id),
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: question.type.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              // Drag reordering
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.drag_handle, 
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Question Text Input
          TextField(
            decoration: const InputDecoration(
              labelText: 'Question Text',
              hintText: 'Enter your question here...',
              isDense: true,
            ),
            onChanged: (value) {
              onQuestionUpdated(index, question.copyWith(text: value));
            },
          ),
          const SizedBox(height: 12),
          
          // Question Type 
          _buildQuestionWidget(context, question, index),
          
          const SizedBox(height: 12),
          
          // Bottom row Required and Delete button
          Row(
            children: [
              Row(
                children: [
                  const Text('Required', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Switch(
                    value: question.isRequired,
                    onChanged: (value) {
                      onQuestionUpdated(index, question.copyWith(isRequired: value));
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const Spacer(),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => onQuestionDeleted(index),
                tooltip: 'Delete Question',
                iconSize: 20,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              // Move Up button demo
              //IconButton(
                //icon: const Icon(Icons.keyboard_arrow_up, color: AppConstants.primaryColor),
                //onPressed: index > 0 ? () => onMoveQuestionUp?.call(index) : null,
                //tooltip: 'Move Up',
                //iconSize: 20,
                //constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
             // ),
              
              // Move Down button demo
              //IconButton(
                //icon: const Icon(Icons.keyboard_arrow_down, color: AppConstants.primaryColor),
                //onPressed: index < questions.length - 1 ? () => onMoveQuestionDown?.call(index) : null,
                //tooltip: 'Move Down',
                //iconSize: 20,
                //constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              //),
              //const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildQuestionWidget(BuildContext context, Question question, int index) {
    switch (question.type) {
      case QuestionType.textInput:
        return TextInputWidget(
          question: question,
          onUpdate: (updatedQuestion) => onQuestionUpdated(index, updatedQuestion),
          isBuilder: true,
        );
      case QuestionType.multipleChoice:
        return MultipleChoiceWidget(
          question: question,
          onUpdate: (updatedQuestion) => onQuestionUpdated(index, updatedQuestion),
          isBuilder: true,
        );
      case QuestionType.starRating:
        return StarRatingWidget(
          question: question,
          onUpdate: (updatedQuestion) => onQuestionUpdated(index, updatedQuestion),
          isBuilder: true,
        );
      case QuestionType.percentageScale:
        return PercentageScaleWidget(
          question: question,
          onUpdate: (updatedQuestion) => onQuestionUpdated(index, updatedQuestion),
          isBuilder: true,
        );
      case QuestionType.ranking:
        return RankingWidget(
          question: question,
          onUpdate: (updatedQuestion) => onQuestionUpdated(index, updatedQuestion),
          isBuilder: true,
        );
      case QuestionType.barChart:
        return BarChartWidget(
          question: question,
          onUpdate: (updatedQuestion) => onQuestionUpdated(index, updatedQuestion),
          isBuilder: true,
        );
      case QuestionType.fileUpload:
        return FileUploadWidget(
          question: question,
          onUpdate: (updatedQuestion) => onQuestionUpdated(index, updatedQuestion),
          isBuilder: true,
        );
    }
  }

Widget _buildDropZone() {
  return DragTarget<QuestionType>(
    onAcceptWithDetails: (details) {
      onQuestionAdded(details.data);
    },
    builder: (context, candidateData, rejectedData) {
      final bool isHovering = candidateData.isNotEmpty;
      
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: DottedBorder(
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: isHovering
                  ? Colors.blue
                  : Colors.grey,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isHovering ? Icons.add_circle : Icons.add_circle_outline,
                    size: 40,
                    color: isHovering ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHovering
                        ? 'Drop question tool here!'
                        : 'Drag to add questions here',
                    style: TextStyle(
                      fontSize: 16,
                      color: isHovering
                          ? Colors.blue
                          : Colors.grey.shade600,
                      fontWeight: isHovering
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isHovering) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Or click the tools in the left panel',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
}