import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/local_storage_service.dart';
import '../../models/user_model.dart';
import '../../utilities/constants.dart';
import '../../utilities/routes.dart';
import '../../utilities/validators.dart';
import 'package:flutter/foundation.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isUploadingImage = false;
  File? _selectedImage;
  String? _currentPhotoPath;
  UserModel? _currentUser;
  final ImagePicker _picker = ImagePicker();
  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final userData = await AuthService.getUserData(user.uid);
        if (userData != null) {
          setState(() {
            _currentUser = userData;
            _nameController.text = userData.displayName;
            _emailController.text = userData.email;
            _currentPhotoPath = userData.photoURL;
          });
        } else {
          // Fallback to Firebase Auth user data
          setState(() {
            _nameController.text = user.displayName ?? 'User';
            _emailController.text = user.email ?? '';
            _currentPhotoPath = user.photoURL;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImage(ImageSource.camera);
                },
              ),
              if (_currentPhotoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image source: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    setState(() {
      _selectedImage = null;
      _currentPhotoPath = null;
    });
  }

  Widget _buildProfileImage() {
    Widget imageWidget;
    
    if (_selectedImage != null) {
      imageWidget = Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
      );
    } else if (_currentPhotoPath != null && _currentPhotoPath!.isNotEmpty) {
      // Check local path or URL
      if (_currentPhotoPath!.startsWith('http')) {
        imageWidget = Image.network(
          _currentPhotoPath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 60,
              color: Colors.grey[400],
            );
          },
        );
      } else {
        // Local file path
        imageWidget = Image.file(
          File(_currentPhotoPath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 60,
              color: Colors.grey[400],
            );
          },
        );
      }
    } else {
      imageWidget = Icon(
        Icons.person,
        size: 60,
        color: Colors.grey[400],
      );
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: AppConstants.primaryColor,
      child: ClipOval(
        child: SizedBox(
          width: 120,
          height: 120,
          child: imageWidget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = AuthService.isGuest;
    
    return Scaffold(
      body: Column(
        children: [
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
                        if (isGuest)
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
                      'Edit Profile',
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
        Container(
          width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.profile);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                         ),
                        ],
                      ),
                   ),
                  ),
                ],
              ),
              ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Image 
                    Center(
                      child: Stack(
                        children: [
                          _buildProfileImage(),
                          if (_isUploadingImage)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  ),
                                ),
                              ),
                        if (!isGuest)
                           Positioned(
                            bottom: 0,
                            right: 0,
                              child: GestureDetector(
                                onTap: _isUploadingImage ? null : _pickImage,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: _isUploadingImage ? Colors.grey : AppConstants.primaryColor,
                                  ),
                                 ),
                               ),
                               ),
                            ],
                         ),
                        ),
                    const SizedBox(height: 32),

                    // Guest should signin dialog
                    if (isGuest) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 48,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Guest Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a permanent account to save your surveys, earn rewards, and access all features.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.amber[700],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _upgradeAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Upgrade Account'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                     // Name box
                     TextFormField(
                       controller: _nameController,
                        decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Enter your full name',
                      ),
                      validator: Validators.validateName,
                      enabled: !isGuest,
                      onChanged: (value) {
                        setState(() {}); 
                        },
                      ),
                      const SizedBox(height: 16),

                    // Email box
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                        helperText: isGuest ? 'Upgrade account to set email' : null,
                      ),
                      validator: isGuest ? null : Validators.validateEmail,
                      enabled: false, // Email can't be edit
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isLoading || isGuest) ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isGuest ? 'Create Account to Save' : 'Save Changes',
                                style: TextStyle(
                                  color: isGuest ? Colors.grey : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

          // Bottom navigation
          Container(
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
                  if (!isGuest)
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

Future<void> _upgradeAccount() async {
    // Guest should signin dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Account'),
        content: const Text(
          'Enter your email and password to convert your guest account to a permanent account. This will save all your data and unlock all features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showUpgradeForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpgradeForm() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Account'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validatePassword,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Validators.validateConfirmPassword(
                  value,
                  passwordController.text,
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _performAccountUpgrade(
                  emailController.text.trim(),
                  passwordController.text,
                  );
                }
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Create Account', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performAccountUpgrade(String email, String password) async {
    setState(() => _isLoading = true);

    try {
      await AuthService.linkWithEmailPassword(
        email,
        password,
        _nameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account upgraded successfully!'),
            backgroundColor: Colors.green,
            ),
          );
        
            // Reload user data
            await _loadUserData();
            }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error upgrading account: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
               }
            } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                    }
                  }
                }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? photoPath = _currentPhotoPath;

      // Save new image if selected
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);
        try {
          final user = AuthService.currentUser!;
          photoPath = await _storageService.saveProfilePicture(
            _selectedImage!.path, 
            user.uid
          );
          
          if (kDebugMode) {
            print('Profile picture saved locally: $photoPath');
          }
        } finally {
          setState(() => _isUploadingImage = false);
        }
      }

      // Update user data
      final user = AuthService.currentUser!;
      await user.updateDisplayName(_nameController.text.trim());
      if (photoPath != null) {
        await user.updatePhotoURL(photoPath);
      }

      // Update local user data
      final updatedUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: _nameController.text.trim(),
        photoURL: photoPath ?? '',
        isAnonymous: user.isAnonymous,
        totalRewards: _currentUser?.totalRewards ?? 0,
        createdAt: _currentUser?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await AuthService.updateUserData(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to profile screen
      Navigator.pushNamed(context, Routes.profile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
