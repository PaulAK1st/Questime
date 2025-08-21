import 'package:flutter/material.dart';
import '../models/survey_model.dart';
import '../utilities/constants.dart';

class SurveyDetailScreen extends StatelessWidget {
  final Survey survey;
  final bool isGuest;

  const SurveyDetailScreen({
    super.key,
    required this.survey,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(survey.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: AppConstants.primaryColor),
            SizedBox(height: 16),
            Text(
              'Survey Detail Screen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Survey taking functionality coming soon!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  } 