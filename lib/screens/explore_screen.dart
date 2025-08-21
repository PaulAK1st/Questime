import 'package:flutter/material.dart';
//import '../models/survey_model.dart';
import '../utilities/constants.dart';
import '../utilities/routes.dart';
import '../screens/create_survey_screen.dart';
//import 'create_survey_screen.dart';

class ExploreScreen extends StatefulWidget {
  final bool isGuest;

  const ExploreScreen({super.key, required this.isGuest});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final List<bool> _bookmarkedSurveys = [false, false, false];
  
// Sample survey data
final List<Map<String, dynamic>> _sampleSurveys = [
  { // Survey offers rewards
    'title': 'Coffee Shop Customer Satisfaction Survey',
    'keywords': ['customer', 'satisfaction', 'service', 'feedback'],
    'hasReward': true, 
    'questionCount': 8,
    'dueDate': '2025-12-31',
  },
  { // Survey doesn't offer rewards
    'questionCount': 5,
    'title': 'Political Opinion Survey',
    'keywords': ['politics', 'opinion', 'government', 'policy'],
    'hasReward': false, 
    'dueDate': '2025-10-25',
  },
  { // Survey offers rewards
    'title': 'Favorite Football Team Poll',
    'keywords': ['football', 'sport', 'poll', 'trends'],
    'hasReward': true, 
    'questionCount': 12,
    'dueDate': '2025-11-15',
  },
  ];

  List<Map<String, dynamic>> get _filteredSurveys {
    if (_searchQuery.isEmpty) return _sampleSurveys;
    
    return _sampleSurveys.where((survey) {
      final keywords = survey['keywords'] as List<String>;
      final title = survey['title'] as String;
      final query = _searchQuery.toLowerCase();
      
      return title.toLowerCase().contains(query) ||
             keywords.any((keyword) => keyword.toLowerCase().contains(query));
    }).toList();
  }
@override
void initState() {
  super.initState();
  _loadSurveys();
}

Future<void> _loadSurveys() async {
  await _surveyService.getSurveys();
  setState(() {
  });
}

  final SurveyService _surveyService = SurveyService();

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
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo_sym.png',
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.quiz, size: 24, color: Colors.white);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'QuesTime',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      // Return to title button top right
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.welcome,
                            (route) => false,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        child: const Text(
                          'Return to title',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Main content 
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  // Search section
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    color: Colors.white,
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search survey here',
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: Icon(Icons.tune), // Filter icon
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Search results 
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _searchQuery.isEmpty
                                ? ''
                                : _filteredSurveys.isEmpty
                                    ? 'No relevant topic found'
                                    : '${_filteredSurveys.length} found',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Survey list
                  Expanded(
                    child: _filteredSurveys.isEmpty && _searchQuery.isNotEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No surveys found',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppConstants.defaultPadding),
                            itemCount: _filteredSurveys.length,
                            itemBuilder: (context, index) {
                              final survey = _filteredSurveys[index];
                              final originalIndex = _sampleSurveys.indexOf(survey);
                              return _buildSurveyCard(survey, originalIndex);
                            },
                          ),
                  ),
                  
                  // Bottom navigation
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA), // White grey
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Explore (highlighted)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.explore,
                                color: AppConstants.primaryColor,
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                                  size: 28,
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
                  ),
                ],
              ),
              
              // + Button 
              Positioned(
                bottom: 80, 
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.createSurvey);
                  },
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

Widget _buildSurveyCard(Map<String, dynamic> survey, int index) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16.0),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Survey banner with bookmark and reward
        Stack(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Icon(
                Icons.image,
                size: 40,
                color: Colors.grey,
              ),
            ),
            // Reward badge (top left)
            if (survey['hasReward'] == true)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber,
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Reward',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            // Bookmark icon (top right)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _bookmarkedSurveys[index] = !_bookmarkedSurveys[index];
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _bookmarkedSurveys[index] 
                            ? 'Survey bookmarked!' 
                            : 'Bookmark removed',
                      ),
                      duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _bookmarkedSurveys[index] 
                        ? Icons.bookmark 
                        : Icons.bookmark_border,
                    color: _bookmarkedSurveys[index] 
                        ? AppConstants.primaryColor 
                        : Colors.grey[600],
                    size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        
        // Survey content
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with reward check
              Row(
                children: [
                  Expanded(
                    child: Text(
                      survey['title'],
                      style: const TextStyle(
                        fontSize: 18,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 8),
              
              // Due date and question count
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${survey['dueDate']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.quiz,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${survey['questionCount']} questions',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              // Show reward info (if available)
              if (survey['hasReward'] == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 15),
                      const SizedBox(width: 4),
                      Text(
                        'Complete survey for reward!',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber[800],
                          fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
  }



