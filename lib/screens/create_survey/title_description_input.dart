import 'package:flutter/material.dart';
import '../../utilities/constants.dart';

class TitleDescriptionInput extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const TitleDescriptionInput({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.edit, color: AppConstants.primaryColor),
            SizedBox(width: 8),
            Text(
              'Survey Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Survey Title *',
            hintText: 'Enter your survey title...',
            prefixIcon: Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Survey Description',
            hintText: 'Describe what your survey is about...',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
