import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utilities/constants.dart';
import '../utilities/routes.dart';
import '../utilities/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sign in controllers 
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  
  // Sign up controllers
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Demo credentials for testing
    _signInEmailController.text = 'demo@example.com';
    _signInPasswordController.text = 'password123';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
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
                        // Back button to welcome screen
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
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
                        // Demo info button
                        IconButton(
                          icon: const Icon(Icons.info_outline, color: Colors.white),
                          onPressed: _showDemoInfo,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 24,
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
          
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppConstants.primaryColor,
              labelColor: AppConstants.primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Sign In'),
                Tab(text: 'Sign Up'),
                ],
              ),
            ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSignInForm(),
                _buildSignUpForm(),
                ],
              ),
            ),
          
          // Guest Login 
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            child: Column(
              children: [
                Text(
                  'Or continue as guest',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 450,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signInAsGuest,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppConstants.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline, color: AppConstants.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Continue as Guest',
                                style: TextStyle(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                             ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

  Widget _buildSignInForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _signInFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _signInEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signInPasswordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppConstants.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 450,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

  Widget _buildSignUpForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _signUpFormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _signUpNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _signUpEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _signUpPasswordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) => Validators.validateConfirmPassword(value, _signUpPasswordController.text),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 450,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
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
            );
          }

  Future<void> _signIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signInWithEmailPassword(
        _signInEmailController.text.trim(),
        _signInPasswordController.text,
      );

      if (!mounted) return;
      Routes.navigateToExplore(context, isGuest: false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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

  Future<void> _signUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signUpWithEmailPassword(
        _signUpEmailController.text.trim(),
        _signUpPasswordController.text,
        _signUpNameController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Routes.navigateToExplore(context, isGuest: false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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

  Future<void> _signInAsGuest() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.signInAnonymously();
      if (!mounted) return;
      Routes.navigateToExplore(context, isGuest: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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

  Future<void> _forgotPassword() async {
    final email = _signInEmailController.text.trim();
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await AuthService.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent!'),
            backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

  void _showDemoInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo Information'),
        content: const Text(
          'Demo credentials are pre-filled for testing:\n\n'
          'Email: demo@example.com\n'
          'Password: password123\n\n'
          'You can also:\n'
          '• Create a new account\n'
          '• Continue as a guest\n'
          '• Use any valid email/password for testing'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}