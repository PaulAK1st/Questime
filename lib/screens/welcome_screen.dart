import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utilities/constants.dart';
import '../utilities/routes.dart';
import 'explore_screen.dart';
import 'login_screen.dart'; 

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/qtscreen2.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/qt_logo.png',
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.quiz,
                          size: 120,
                          color: Colors.white,
                        );
                      },
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'Challenge the quests \nSpark the communities',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.alegreya(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Sign In / Sign Up Button 
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          debugPrint('Sign In / Sign Up button pressed');
                          try {
                            // Using Routes helper 
                            Routes.navigateToLogin(context);
                          } catch (e) {
                            debugPrint('Routes.navigateToLogin failed: $e');
                            // Or direct route navigation
                            try {
                              Navigator.pushNamed(context, Routes.login);
                            } catch (e2) {
                              debugPrint('pushNamed failed: $e2');
                              // Or direct MaterialPageRoute (fallback)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                  ),
                                );
                              }
                            }
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Sign In / Sign Up',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Continue as Guest Button 
                    SizedBox(
                      width: 300,
                      child: OutlinedButton(
                        onPressed: () {
                          debugPrint('Continue as Guest button pressed');
                          try {
                            Routes.navigateToExplore(context, isGuest: true);
                          } catch (e) {
                            debugPrint('Routes.navigateToExplore failed: $e');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExploreScreen(isGuest: true),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Continue as Guest',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Guest mode has no rewards',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
