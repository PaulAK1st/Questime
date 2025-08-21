import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  static const String _logFileName = 'survey_app_logs.txt';
  File? _logFile;
  bool _isInitialized = false;

  // Initialise the logger
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        _logFile = File('${directory.path}/$_logFileName');
        
        // Create log file if it doesn't exist
        if (!await _logFile!.exists()) {
          await _logFile!.create(recursive: true);
        }
      }
      _isInitialized = true;
      info('AppLogger initialized successfully');
    } catch (e) {
      developer.log('Failed to initialize AppLogger: $e');
    }
  }

  // Log debug messages
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _instance._log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Log info messages
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _instance._log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Log warning messages
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _instance._log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Log error messages
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _instance._log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Log critical messages
  static void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _instance._log(LogLevel.critical, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Log survey-specific events
  static void surveyEvent(String event, Map<String, dynamic>? data, {String? surveyId}) {
    final message = 'Survey Event: $event${surveyId != null ? ' (Survey: $surveyId)' : ''}';
    final details = data != null ? ' - Data: $data' : '';
    _instance._log(LogLevel.info, '$message$details', tag: 'SURVEY');
  }

  // Log question interactions
  static void questionInteraction(String questionId, String action, {dynamic value}) {
    final message = 'Question Interaction - ID: $questionId, Action: $action';
    final valueStr = value != null ? ', Value: $value' : '';
    _instance._log(LogLevel.debug, '$message$valueStr', tag: 'QUESTION');
  }

  // Log validation events
  static void validation(String message, {String? fieldId, bool isError = false}) {
    final level = isError ? LogLevel.error : LogLevel.info;
    final formattedMessage = 'Validation${fieldId != null ? ' ($fieldId)' : ''}: $message';
    _instance._log(level, formattedMessage, tag: 'VALIDATION');
  }

  // Log navigation events
  static void navigation(String from, String to, {Map<String, dynamic>? params}) {
    final message = 'Navigation: $from -> $to';
    final paramStr = params != null ? ' with params: $params' : '';
    _instance._log(LogLevel.info, '$message$paramStr', tag: 'NAVIGATION');
  }

  // Log API calls
  static void api(String endpoint, String method, {int? statusCode, String? error}) {
    final message = 'API Call: $method $endpoint';
    String details = '';
    if (statusCode != null) details += ' - Status: $statusCode';
    if (error != null) details += ' - Error: $error';
    
    final level = error != null ? LogLevel.error : LogLevel.info;
    _instance._log(level, '$message$details', tag: 'API');
  }

  // Log performance metrics
  static void performance(String operation, Duration duration, {Map<String, dynamic>? metrics}) {
    final message = 'Performance: $operation took ${duration.inMilliseconds}ms';
    final metricsStr = metrics != null ? ' - Metrics: $metrics' : '';
    _instance._log(LogLevel.debug, '$message$metricsStr', tag: 'PERFORMANCE');
  }

  // Internal logging method
  void _log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!_isInitialized) {
      developer.log('Logger not initialized: $message');
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(8);
    final tagStr = tag != null ? '[$tag] ' : '';
    final errorStr = error != null ? '\nError: $error' : '';
    final stackStr = stackTrace != null ? '\nStack: $stackTrace' : '';
    
    final logMessage = '$timestamp $levelStr $tagStr$message$errorStr$stackStr';

    // Print to console in debug mode
    if (kDebugMode) {
      _printWithColor(level, logMessage);
    }

    // Write to developer console
    developer.log(
      message,
      time: DateTime.now(),
      level: _getLogLevelInt(level),
      name: tag ?? 'AppLogger',
      error: error,
      stackTrace: stackTrace,
    );

    // Write to file if not web
    if (!kIsWeb && _logFile != null) {
      _writeToFile(logMessage);
    }
  }

  // Print with color coding for different log levels
  void _printWithColor(LogLevel level, String message) {
    const String reset = '\x1B[0m';
    String color;

    switch (level) {
      case LogLevel.debug:
        color = '\x1B[37m'; // White
        break;
      case LogLevel.info:
        color = '\x1B[32m'; // Green
        break;
      case LogLevel.warning:
        color = '\x1B[33m'; // Yellow
        break;
      case LogLevel.error:
        color = '\x1B[31m'; // Red
        break;
      case LogLevel.critical:
        color = '\x1B[35m'; // Magenta
        break;
    }
    if (kDebugMode) {
      debugPrint('$color$message$reset');
    }  
  }

  // Convert log level to integer 
  int _getLogLevelInt(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }

  // Write to log file
  Future<void> _writeToFile(String message) async {
    try {
      await _logFile?.writeAsString('$message\n', mode: FileMode.append);
    } catch (e) {
      developer.log('Failed to write to log file: $e');
    }
  }

  // Get log file path
  Future<String?> getLogFilePath() async {
    if (kIsWeb || _logFile == null) return null;
    return _logFile!.path;
  }

  // Clear log file
  Future<void> clearLogs() async {
    if (kIsWeb || _logFile == null) return;
    
    try {
      await _logFile!.writeAsString('');
      info('Log file cleared');
    } catch (e) {
      error('Failed to clear log file', error: e);
    }
  }

  // Get log file size
  Future<int?> getLogFileSize() async {
    if (kIsWeb || _logFile == null) return null;
    
    try {
      if (await _logFile!.exists()) {
        return await _logFile!.length();
      }
    } catch (e) {
      error('Failed to get log file size', error: e);
    }
    return null;
  }

  // Read recent logs
  Future<List<String>> getRecentLogs({int lines = 100}) async {
    if (kIsWeb || _logFile == null) return [];

    try {
      if (await _logFile!.exists()) {
        final content = await _logFile!.readAsString();
        final allLines = content.split('\n');
        final recentLines = allLines.length > lines 
          ? allLines.sublist(allLines.length - lines)
          : allLines;
        return recentLines.where((line) => line.isNotEmpty).toList();
      }
    } catch (e) {
      error('Failed to read recent logs', error: e);
    }
    return [];
  }

  // Export logs
  Future<String?> exportLogs() async {
    if (kIsWeb || _logFile == null) return null;

    try {
      if (await _logFile!.exists()) {
        return await _logFile!.readAsString();
      }
    } catch (e) {
      error('Failed to export logs', error: e);
    }
    return null;
  }

  // Log app lifecycle events
  static void appLifecycle(String event, {Map<String, dynamic>? data}) {
    final message = 'App Lifecycle: $event';
    final dataStr = data != null ? ' - $data' : '';
    _instance._log(LogLevel.info, '$message$dataStr', tag: 'LIFECYCLE');
  }

  // Log memory usage 
  static void memoryUsage(int usedMB, {int? totalMB}) {
    final message = 'Memory Usage: ${usedMB}MB';
    final totalStr = totalMB != null ? ' / ${totalMB}MB' : '';
    _instance._log(LogLevel.debug, '$message$totalStr', tag: 'MEMORY');
  }

  // Log network connectivity
  static void networkStatus(bool isConnected, {String? connectionType}) {
    final status = isConnected ? 'Connected' : 'Disconnected';
    final typeStr = connectionType != null ? ' ($connectionType)' : '';
    _instance._log(LogLevel.info, 'Network: $status$typeStr', tag: 'NETWORK');
  }

  // Log user actions for analytics
  static void userAction(String action, {Map<String, dynamic>? properties}) {
    final message = 'User Action: $action';
    final propStr = properties != null ? ' - Properties: $properties' : '';
    _instance._log(LogLevel.info, '$message$propStr', tag: 'USER_ACTION');
  }

  // Dispose resources
  void dispose() {
    // Clean up resources if needed
    info('AppLogger disposed');
  }

  static void surveyInfo(String s) {}

  static void surveyError(String s, Object e) {}
}
