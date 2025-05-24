import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// A service class that handles saving and retrieving user progress data.
/// This includes grades, time taken, and completion status for different levels.
class ProgressService {
  static const String _progressKey = 'user_progress';
  static const String _lastGradeKey = 'last_grade';
  static const String _lastTimeKey = 'last_time_taken';

  /// Saves the user's progress for a specific level.
  ///
  /// Parameters:
  /// - [level]: The level number (must be positive)
  /// - [grade]: The grade achieved (must be between 0 and 100)
  /// - [timeTaken]: The time taken in seconds (must be positive)
  ///
  /// Throws [ArgumentError] if parameters are invalid
  static Future<void> saveProgress({
    required int level,
    required double grade,
    required double timeTaken,
  }) async {
    // Validate input parameters
    if (level <= 0) {
      throw ArgumentError('Level must be a positive number');
    }
    if (grade < 0 || grade > 100) {
      throw ArgumentError('Grade must be between 0 and 100');
    }
    if (timeTaken < 0) {
      throw ArgumentError('Time taken must be a positive number');
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save the latest grade and time taken
      await prefs.setDouble(_lastGradeKey, grade);
      await prefs.setDouble(_lastTimeKey, timeTaken);

      // Get existing progress
      final progressJson = prefs.getString(_progressKey);
      Map<String, dynamic> progress = {};

      if (progressJson != null) {
        try {
          progress = json.decode(progressJson) as Map<String, dynamic>;
        } catch (e) {
          // If JSON is corrupted, start with empty progress
          progress = {};
        }
      }

      // Update progress for the level
      progress[level.toString()] = {
        'grade': grade,
        'timeTaken': timeTaken,
        'completedAt': DateTime.now().toIso8601String(),
      };

      // Save updated progress
      await prefs.setString(_progressKey, json.encode(progress));
    } catch (e) {
      throw Exception('Failed to save progress: $e');
    }
  }

  /// Retrieves the user's progress for all levels.
  ///
  /// Returns a map where keys are level numbers (as strings) and values are maps
  /// containing grade, time taken, and completion timestamp.
  static Future<Map<String, Map<String, dynamic>>> getProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);

      if (progressJson == null) {
        return {};
      }

      final Map<String, dynamic> decoded = json.decode(progressJson);

      // Convert to strongly typed map
      return decoded.map((key, value) {
        if (value is Map<String, dynamic>) {
          return MapEntry(key, value);
        }
        return MapEntry(key, <String, dynamic>{});
      });
    } catch (e) {
      throw Exception('Failed to get progress: $e');
    }
  }

  /// Gets the latest grade and time taken metrics.
  ///
  /// Returns a map containing the latest grade and time taken.
  /// If no previous metrics exist, returns 0.0 for both values.
  static Future<Map<String, double>> getLatestMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'grade': prefs.getDouble(_lastGradeKey) ?? 0.0,
        'timeTaken': prefs.getDouble(_lastTimeKey) ?? 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get latest metrics: $e');
    }
  }

  /// Clears all saved progress data.
  ///
  /// This will remove all stored progress, including grades, time taken,
  /// and completion status for all levels.
  static Future<void> clearProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
      await prefs.remove(_lastGradeKey);
      await prefs.remove(_lastTimeKey);
    } catch (e) {
      throw Exception('Failed to clear progress: $e');
    }
  }
}
