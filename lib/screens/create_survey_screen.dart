import 'package:flutter/material.dart';
import '../../models/survey_model.dart';
//import '../../services/survey_service.dart';
import '../../services/auth_service.dart';
import '../../services/local_storage_service.dart';
import '../../models/question_model.dart';
import '../../utilities/constants.dart';
import '../screens/create_survey/title_description_input.dart';
import '../screens/create_survey/banner_uploader.dart';
import '../screens/create_survey/question_builder.dart';
import '../screens/create_survey/save_draft_button.dart';
import '../screens/create_survey/question_widgets/survey_share_dialog.dart';
import '../../utilities/routes.dart';
import 'create_survey/question_widgets/drag_drop_tools.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
//import '../models/survey_model.dart';

class CreateSurveyScreen extends StatefulWidget {
  final bool isGuest;

  const CreateSurveyScreen({super.key, required this.isGuest});

  @override
  State<CreateSurveyScreen> createState() => _CreateSurveyScreenState();
}

class _CreateSurveyScreenState extends State<CreateSurveyScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<Question> _questions = [];
  String? _bannerPath; 
  bool _hasReward = false;
  bool _isDragOver = false;
  final SurveyService _surveyService = SurveyService();
  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section 
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
              ),
            ),
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo_sym.png',
                          height: 32,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.quiz, size: 24, color: Colors.white);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'QuesTime',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Save Draft 
                        if (!widget.isGuest)
                          SaveDraftButton(
                            onSave: _saveDraft,
                            enabled: _titleController.text.isNotEmpty,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _titleController.text.isEmpty ? 'Create Survey' : _titleController.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Create survey
          Expanded(
            child: Row(
              children: [
                // Question tools panel 
                Container(
                  width: 80, 
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Tools header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.build,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tools',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Draggable tools
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              DraggableQuestionTool(
                                icon: Icons.text_fields,
                                type: QuestionType.textInput,
                                tooltip: 'Text Input',
                                onTap: () => _addQuestion(QuestionType.textInput),
                              ),
                              DraggableQuestionTool(
                                icon: Icons.radio_button_checked,
                                type: QuestionType.multipleChoice,
                                tooltip: 'Multiple Choice',
                                onTap: () => _addQuestion(QuestionType.multipleChoice),
                              ),
                              DraggableQuestionTool(
                                icon: Icons.linear_scale,
                                type: QuestionType.percentageScale,
                                tooltip: 'Percentage Scale',
                                onTap: () => _addQuestion(QuestionType.percentageScale),
                              ),
                              DraggableQuestionTool(
                                icon: Icons.format_list_numbered,
                                type: QuestionType.ranking,
                                tooltip: 'Ranking',
                                onTap: () => _addQuestion(QuestionType.ranking),
                              ),
                              DraggableQuestionTool(
                                icon: Icons.bar_chart,
                                type: QuestionType.barChart,
                                tooltip: 'Bar Chart',
                                onTap: () => _addQuestion(QuestionType.barChart),
                              ),
                              DraggableQuestionTool(
                                icon: Icons.star,
                                type: QuestionType.starRating,
                                tooltip: 'Star Rating',
                                onTap: () => _addQuestion(QuestionType.starRating),
                              ),
                              DraggableQuestionTool(
                                icon: Icons.attach_file,
                                type: QuestionType.fileUpload,
                                tooltip: 'File Upload',
                                onTap: () => _addQuestion(QuestionType.fileUpload),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right panel
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Banner Upload
                          BannerUploader(
                            bannerPath: _bannerPath,
                            onBannerSelected: _handleBannerSelection,
                          ),
                          const SizedBox(height: 16),
                          
                          // Title and description
                          TitleDescriptionInput(
                            titleController: _titleController,
                            descriptionController: _descriptionController,
                          ),
                          const SizedBox(height: 16),
                          
                          // Reward Option
                          if (!widget.isGuest) _buildRewardOption(),
                          if (!widget.isGuest) const SizedBox(height: 20),
                          
                          // Questions section and drop zone
                          _buildQuestionsSection(),
                          
                          const SizedBox(height: 20),
                          // Create survey button
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _createSurvey,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.publish, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Create Survey!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Banner select handler 
  Future<void> _handleBannerSelection(String? path) async {
    if (path != null) {
      try {
        // Save banner local
        final savedPath = await _storageService.saveBanner(path);
        
        if (!mounted) return; 
        
        setState(() {
          _bannerPath = savedPath;
        });
        
        if (kDebugMode) {
          print('Banner saved locally: $savedPath');
        }
        
        if (mounted) { 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Banner saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) { 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving banner: $e')),
          );
        }
      }
    } else {
      // Remove banner
      if (mounted) {
        setState(() {
          _bannerPath = null;
        });
      }
    }
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Questions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Drop zone for adding questions
        if (_questions.isEmpty)
          DragTarget<QuestionType>(
            onWillAcceptWithDetails: (details) => true,
            onAcceptWithDetails: (details) => _addQuestion(details.data),
            onMove: (details) => setState(() => _isDragOver = true),
            onLeave: (data) => setState(() => _isDragOver = false),
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: double.infinity,
                height: 120,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _isDragOver ? Colors.blue[50] : Colors.grey[100],
                  border: Border.all(
                    color: _isDragOver ? Colors.blue : Colors.grey[300]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isDragOver ? Icons.add_circle : Icons.add_circle_outline,
                      size: 32,
                      color: _isDragOver ? Colors.blue : Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drag tools here to add questions\nor tap tools on the left',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: _isDragOver ? Colors.blue : Colors.grey[600],
                        fontWeight: _isDragOver ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        
        // Question builder
        if (_questions.isNotEmpty)
          QuestionBuilder(
            questions: _questions,
            onQuestionAdded: _addQuestion,
            onQuestionUpdated: _updateQuestion,
            onQuestionDeleted: _deleteQuestion,
            onQuestionsReordered: _reorderQuestions,
            onDropAccepted: (QuestionType type) {
              setState(() => _isDragOver = false);
              _addQuestion(type);
            },
          ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Explore
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Profile
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, Routes.profile);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Rewards 
            if (!widget.isGuest)
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.rewards);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      color: Colors.amber[600],
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rewards',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardOption() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _hasReward ? Colors.amber[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _hasReward ? Colors.amber[300]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _hasReward = !_hasReward;
              });
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _hasReward ? Colors.amber : Colors.transparent,
                border: Border.all(
                  color: _hasReward ? Colors.amber : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _hasReward
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      color: _hasReward ? Colors.amber[700] : Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Claimable Reward',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _hasReward ? Colors.amber[800] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _hasReward
                      ? 'QT coin will be awarded to respondents'
                      : 'Enable rewards for survey completion',
                  style: TextStyle(
                    fontSize: 11,
                    color: _hasReward ? Colors.amber[700] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addQuestion(QuestionType type) {
    final newQuestion = Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      type: type,
      order: _questions.length,
      settings: _getDefaultSettings(type),
    );
    
    setState(() {
      _questions.add(newQuestion);
      _isDragOver = false;
    });
  }

  Map<String, dynamic> _getDefaultSettings(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return {
          'options': ['Option 1', 'Option 2', 'Option 3'],
          'allowOther': false,
        };
      case QuestionType.ranking:
        return {
          'items': ['Item 1', 'Item 2', 'Item 3'],
        };
      case QuestionType.percentageScale:
        return {
          'min': 0,
          'max': 100,
          'step': 1,
        };
      case QuestionType.starRating:
        return {
          'maxStars': 5,
        };
      default:
        return {};
    }
  }

  void _updateQuestion(int index, Question question) {
    setState(() {
      _questions[index] = question;
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      // Update order for remaining questions
      for (int i = 0; i < _questions.length; i++) {
        _questions[i] = _questions[i].copyWith(order: i);
      }
    });
  }

  void _reorderQuestions(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Question item = _questions.removeAt(oldIndex);
      _questions.insert(newIndex, item);
      
      // Update order for all questions
      for (int i = 0; i < _questions.length; i++) {
        _questions[i] = _questions[i].copyWith(order: i);
      }
    });
  }

  Future<void> _saveDraft() async {
    if (_titleController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a survey title to save draft'),
          ),
        );
      }
      return;
    }

    try {
      final surveyId = DateTime.now().millisecondsSinceEpoch.toString();
      final survey = Survey(
        id: surveyId,
        title: _titleController.text,
        description: _descriptionController.text,
        bannerUrl: _bannerPath, // Use local path
        questions: _questions,
        hasReward: _hasReward,
        createdAt: DateTime.now(), 
        ownerId: AuthService.currentUser?.uid ?? '',
      );

      await _surveyService.saveDraft(survey);

      if (!mounted) return; 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft saved successfully!'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving draft: $e')),
      );
    }
  }

  Future<void> _createSurvey() async {
    if (_titleController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a survey title')),
        );
      }
      return;
    }

    if (_questions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one question')),
        );
      }
      return;
    }

    final surveyId = DateTime.now().millisecondsSinceEpoch.toString();
    final survey = Survey(
      id: surveyId,
      title: _titleController.text,
      description: _descriptionController.text,
      bannerUrl: _bannerPath, 
      questions: _questions,
      hasReward: _hasReward && !widget.isGuest, 
      createdAt: DateTime.now(), 
      ownerId: AuthService.currentUser?.uid ?? '',
    );

    // loading 
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      await _surveyService.createSurvey(survey);

      if (!mounted) return; 
      
      Navigator.of(context).pop(); 

      if (widget.isGuest) {
        // Guest success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Survey created successfully! Note: Guest surveys are temporary.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        // Registered user dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SurveyShareDialog(
            surveyId: surveyId,
            surveyTitle: survey.title,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; 
      
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating survey: $e')),
      );
    }
  }
}



class SurveyService {
  static const String _key = "saved_surveys";

  Future<void> createSurvey(Survey survey) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    existing.add(jsonEncode(survey.toJson())); // Save survey JSON
    await prefs.setStringList(_key, existing);
  }

  Future<List<Survey>> getSurveys() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    return saved.map((s) => Survey.fromJson(jsonDecode(s))).toList();
  }

  Future<void> saveDraft(Survey survey) async {
    await createSurvey(survey);
  }
}
