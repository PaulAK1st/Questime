import 'package:flutter/material.dart';
import '../../../models/question_model.dart';

class StarRatingWidget extends StatefulWidget {
  final Question question;
  final Function(Question)? onUpdate;
  final bool isBuilder;

  const StarRatingWidget({
    super.key,
    required this.question,
    this.onUpdate,
    this.isBuilder = false,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    const maxStars = 5; 

    if (widget.isBuilder) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Star Rating Settings:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              SizedBox(width: 8),
              Text(
                '(Fixed to 5 stars)',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Preview (Click to test):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildStarPreview(maxStars, true),
        ],
      );
    }

    return _buildStarPreview(maxStars, false);
  }

Widget _buildStarPreview(int maxStars, bool isTestMode) {
    return Column(
      children: [
        if (isTestMode && _selectedRating > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Rating: $_selectedRating out of $maxStars stars',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxStars, (index) {
            final starIndex = index + 1;
            final isSelected = starIndex <= _selectedRating;
            
            return GestureDetector(
              onTap: isTestMode ? () {
                setState(() {
                  _selectedRating = starIndex;
                });
              } : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
              ),
            );
          }),
          ),
        if (isTestMode) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedRating = 0;
                  });
                },
                child: const Text(
                  'Clear Rating',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        Text(
          'Click stars to test rating functionality',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  // Unused spare
  //void _updateSetting(String key, dynamic value) {
    //if (widget.onUpdate != null) {
      //final settings = Map<String, dynamic>.from(widget.question.settings);
      //settings[key] = value;
      //widget.onUpdate!(widget.question.copyWith(settings: settings));
    //}
  //}
}
