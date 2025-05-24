import 'package:shared_preferences.dart';
import 'dart:convert';

class ProgressService {
  static const String _progressKey = 'user_progress';
  static const String _lastGradeKey = 'last_grade';
  static const String _lastTimeKey = 'last_time_taken';

  // Save user's progress
  static Future<void> saveProgress({
    required int level,
    required double grade,
    required double timeTaken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save the latest grade and time taken
    await prefs.setDouble(_lastGradeKey, grade);
    await prefs.setDouble(_lastTimeKey, timeTaken);

    // Get existing progress
    final progressJson = prefs.getString(_progressKey);
    Map<String, dynamic> progress = {};

    if (progressJson != null) {
      progress = json.decode(progressJson);
    }

    // Update progress for the level
    progress[level.toString()] = {
      'grade': grade,
      'timeTaken': timeTaken,
      'completedAt': DateTime.now().toIso8601String(),
    };

    // Save updated progress
    await prefs.setString(_progressKey, json.encode(progress));
  }

  // Get user's progress
  static Future<Map<String, dynamic>> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);

    if (progressJson == null) {
      return {};
    }

    return json.decode(progressJson);
  }

  // Get latest grade and time taken
  static Future<Map<String, double>> getLatestMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'grade': prefs.getDouble(_lastGradeKey) ?? 0.0,
      'timeTaken': prefs.getDouble(_lastTimeKey) ?? 0.0,
    };
  }

  // Clear all progress
  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_lastGradeKey);
    await prefs.remove(_lastTimeKey);
  }
}
