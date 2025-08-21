import '../models/survey_model.dart';

class GuestService {
  static const Duration _guestSessionDuration = Duration(hours: 1);
  static DateTime? _sessionStartTime;
  static final List<Survey> _guestSurveys = [];

  static void startGuestSession() {
    _sessionStartTime = DateTime.now();
  }

  static bool isSessionExpired() {
    if (_sessionStartTime == null) return true;
    return DateTime.now().difference(_sessionStartTime!) > _guestSessionDuration;
  }

  static void endGuestSession() {
    _sessionStartTime = null;
    _guestSurveys.clear();
  }

  static void addGuestSurvey(Survey survey) {
    if (!isSessionExpired()) {
      _guestSurveys.add(survey);
    }
  }

  static List<Survey> getGuestSurveys() {
    if (isSessionExpired()) {
      _guestSurveys.clear();
      return [];
    }
    return _guestSurveys;
  }

  static Duration get remainingTime {
    if (_sessionStartTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_sessionStartTime!);
    final remaining = _guestSessionDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
