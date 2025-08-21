import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/create_survey_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class Routes {
  // Route names
  static const String welcome = '/';
  static const String login = '/login';
  static const String explore = '/explore';
  static const String createSurvey = '/create-survey';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String rewards = '/rewards';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case explore:
        final args = settings.arguments as Map<String, dynamic>?;
        final isGuest = args?['isGuest'] ?? AuthService.isGuest;
        return MaterialPageRoute(
          builder: (_) => ExploreScreen(isGuest: isGuest),
        );

      case createSurvey:
        final args = settings.arguments as Map<String, dynamic>?;
        final isGuest = args?['isGuest'] ?? AuthService.isGuest;
        return MaterialPageRoute(
          builder: (_) => CreateSurveyScreen(isGuest: isGuest),
        );

      case profile:
        final args = settings.arguments as Map<String, dynamic>?;
        final isGuest = args?['isGuest'] ?? AuthService.isGuest;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(isGuest: isGuest),
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        );

      case rewards:
        return MaterialPageRoute(
          builder: (_) => const RewardsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }

  // Helper method to guest navigate 
  static void navigateToExplore(BuildContext context, {bool? isGuest}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      explore,
      (route) => false,
      arguments: {'isGuest': isGuest ?? AuthService.isGuest},
    );
  }

  static void navigateToCreateSurvey(BuildContext context, {bool? isGuest}) {
    Navigator.pushNamed(
      context,
      createSurvey,
      arguments: {'isGuest': isGuest ?? AuthService.isGuest},
    );
  }

  static void navigateToProfile(BuildContext context, {bool? isGuest}) {
    Navigator.pushNamed(
      context,
      profile,
      arguments: {'isGuest': isGuest ?? AuthService.isGuest},
    );
  }

  // Simple navigation methods (not isGuest)
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, login);
  }

  static void navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, editProfile);
  }

  static void navigateToRewards(BuildContext context) {
    Navigator.pushNamed(context, rewards);
  }

  static void navigateToWelcome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      welcome,
      (route) => false,
    );
  }
}