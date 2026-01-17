import 'dart:developer' as developer;

class AppLogger {
  static void debug(String message, [String? tag]) {
    developer.log(message, name: tag ?? 'App');
  }

  static void info(String message, [String? tag]) {
    developer.log(message, name: tag ?? 'App', level: 800);
  }

  static void warning(String message, [String? tag]) {
    developer.log(message, name: tag ?? 'App', level: 900);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    developer.log(
      message,
      name: tag ?? 'App',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
