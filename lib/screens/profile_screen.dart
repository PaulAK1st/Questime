import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../utilities/constants.dart';
import '../utilities/routes.dart';
import '../screens/survey_manage/survey_created_screen.dart';
import '../screens/survey_manage/survey_completed_screen.dart';
import '../screens/survey_manage/survey_participant_screen.dart';
import 'survey_manage/saved_survey_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool isGuest;

  const ProfileScreen({super.key, required this.isGuest});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImagePath;
  bool _isUploadingImage = false;
  String? _cachedUserName;
  final LocalStorageService _storageService = LocalStorageService();
  
  // Mock user data 
  String get _userName {
    if (_cachedUserName != null) {
      return _cachedUserName!;
    }
    return widget.isGuest ? 'Guest' : 'Loading...';
  }
  
  String get _userType => 'Academic';
  int get _surveysCreated => 0;
  int get _surveyParticipations => 0;
  int get _savedSurveys => 0; 
  int get _totalParticipants => 0;
  
  // Mock recent survey data
  Map<String, dynamic>? get _recentSurvey => null; // Set to null for no surveys

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserName();
  }

  Future<String> _getCurrentUserName() async {
    if (widget.isGuest) {
      return 'Guest';
    }
    
    try {
      // Get saved name from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('user_name');
      
      if (savedName != null && savedName.isNotEmpty) {
        return savedName;
      }
      
      // Fallback to Firebase user data
      if (!kIsWeb) {
        final user = FirebaseAuth.instance.currentUser;
        return user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
      }
      
        return 'Web User';
      } catch (e) {
        return 'Demo User';
      }
    }

  Future<void> _loadUserName() async {
    final name = await _getCurrentUserName();
    if (mounted) {
      setState(() {
        _cachedUserName = name;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    if (!widget.isGuest && !kIsWeb) {
      try {
        // Get local profile image path
        final prefs = await SharedPreferences.getInstance();
        final localPath = prefs.getString('profile_image_path');
        
        if (localPath != null && await File(localPath).exists()) {
          setState(() {
            _profileImagePath = localPath;
          });
          return;
        }
        
        // Fallback to Firebase user data (if URL exists)
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.photoURL != null) {
          setState(() {
            _profileImagePath = user.photoURL;
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading profile: $e'); //Continue with no profile
          }
        }
      }
    }

  void _navigateToSurveyCreatedScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SurveyCreatedScreen(),
      ),
    );
  }

  void _navigateToSurveyCompletedScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SurveyCompletedScreen(),
      ),
    );
  }

  void _navigateToSurveyParticipantScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SurveyParticipantScreen(),
      ),
    );
  }

  void _navigateToSavedSurveyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedSurveyScreen(),
      ),
    );
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
                        // Return to title button on top right
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
                      'Profile',
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
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome box 
                      Container(
                        width: 300,
                        height: 120,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            // Profile image local storage
                            Stack(
                              children: [
                                ProfileUploader(
                                  profilePath: _profileImagePath,
                                  isLoading: _isUploadingImage,
                                  isGuest: widget.isGuest,
                                  onProfileSelected: _handleProfileImageUpload,
                                ),
                                if (_isUploadingImage)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Welcome text and user info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Welcome back, $_userName!',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // User type and Edit profile button 
                                  Row(
                                    children: [
                                      Text(
                                        '$_userType user',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      if (!widget.isGuest)
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Navigate to edit profile 
                                            final result = await Navigator.pushNamed(
                                              context, 
                                              Routes.editProfile,
                                            );
                                            // Refresh when return
                                            if (result == true) {
                                              _loadUserName();
                                              _loadUserProfile();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppConstants.primaryColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            minimumSize: const Size(80, 20),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            'Edit profile',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(height: 12),
                      
                      // Survey stats boxes
                      Row(
                        children: [
                          // Survey Created
                          Expanded(
                            child: GestureDetector(
                              onTap: _navigateToSurveyCreatedScreen,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.pink[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.pink[200]!),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Survey Created',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$_surveysCreated',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          // Survey Completed 
                          Expanded(
                            child: GestureDetector(
                              onTap: _navigateToSurveyCompletedScreen,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Survey Completed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$_surveyParticipations',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      
                      // Total Participants and Saved reward
                      Row(
                        children: [
                          // Total Participants
                          Expanded(
                            child: GestureDetector(
                              onTap: _navigateToSurveyParticipantScreen,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Total Participants',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$_totalParticipants',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Saved reward 
                          Expanded(
                            child: GestureDetector(
                              onTap: _navigateToSavedSurveyScreen,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.amber[100]!, Colors.amber[200]!],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber[300]!),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Saved Surveys',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.amber[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_savedSurveys',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),             
                      // Recent activity
                      const Text(
                        'Recent activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Recent survey or empty message 
                      _recentSurvey != null 
                          ? _buildRecentSurveyCard(_recentSurvey!)
                          : _buildEmptyStateCard(),
                          
                      const SizedBox(height: 80), 
                    ],
                  ),
                ),
                
                // + Button 
                Positioned(
                  bottom: 8, 
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
                  // Explore
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.explore);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          color: Colors.grey[600],
                          size: 28,
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
                  
                  // Profile (highlighted)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        color: AppConstants.primaryColor,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                            size: 28,
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
        );
      }

  Future<void> _handleProfileImageUpload(String? localPath) async {
    if (localPath == null || widget.isGuest) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Save profile image local
      final savedPath = await _storageService.saveProfilePicture(localPath, user.uid);

      // Save path to SharedPreferences for future use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', savedPath);

      // Update user profile with local path
      await user.updatePhotoURL(savedPath);

      // Update local state
      setState(() {
        _profileImagePath = savedPath;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (kDebugMode) {
        print('Profile image saved locally: $savedPath');
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: ${e.toString()}'),
            backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

  Widget _buildRecentSurveyCard(Map<String, dynamic> survey) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Survey banner
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
          
          // Survey content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and reward check
              Row(
                children: [
                    Expanded(
                      child: Text(
                        survey['title'],
                        style: const TextStyle(
                          fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (survey['hasReward'])
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
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
                    ]
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Get ready? Let's start new Quest-ion!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ProfileUploader with local storage
class ProfileUploader extends StatelessWidget {
  final String? profilePath;
  final Function(String?) onProfileSelected;
  final bool isLoading;
  final bool isGuest;

  const ProfileUploader({
    super.key,
    this.profilePath,
    required this.onProfileSelected,
    this.isLoading = false,
    this.isGuest = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGuest ? null : () => _selectProfileImage(context),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[300],
        backgroundImage: _getProfileImage(),
        child: _getProfileImage() == null 
            ? Icon(
                Icons.person,
                size: 30,
                color: Colors.grey[600],
              )
            : null,
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (profilePath == null) return null;
    
    // Check URL or local path
    if (profilePath!.startsWith('http')) {
      return NetworkImage(profilePath!);
    } else {
      // Local file
      return FileImage(File(profilePath!));
    }
  }

  Future<void> _selectProfileImage(BuildContext context) async {
    if (isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to upload profile picture'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        onProfileSelected(image.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
