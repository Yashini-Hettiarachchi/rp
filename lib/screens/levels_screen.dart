import 'package:flutter/material.dart';
import '../constants/env.dart';
import '../widgets/level_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProgressService {
  static Future<Map<String, dynamic>> getProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('user_progress');
      if (progressJson != null) {
        return json.decode(progressJson);
      }
    } catch (e) {
      print('Error loading progress: $e');
    }
    return {};
  }

  static Future<Map<String, dynamic>> getLatestMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = prefs.getString('latest_metrics');
      if (metricsJson != null) {
        return json.decode(metricsJson);
      }
    } catch (e) {
      print('Error loading metrics: $e');
    }
    return {'grade': 0.0, 'timeTaken': 0.0};
  }

  static Future<void> saveProgress(Map<String, dynamic> progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_progress', json.encode(progress));
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  static Future<void> saveMetrics(Map<String, dynamic> metrics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('latest_metrics', json.encode(metrics));
    } catch (e) {
      print('Error saving metrics: $e');
    }
  }

  static Future<Map<String, dynamic>> getPrediction(
      double grade, double timeTaken) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${ENVConfig.predictionUrl}?grade=$grade&time_taken=$timeTaken'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting prediction: $e');
    }
    return {'adjustment': 0.0, 'message': 'Unable to get prediction'};
  }
}

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({Key? key}) : super(key: key);

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  Map<int, bool> levelAccess = {};
  Map<String, dynamic> progress = {};
  Map<String, dynamic> predictions = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load progress data
      final userProgress = await ProgressService.getProgress();
      final metrics = await ProgressService.getLatestMetrics();

      // Get predictions for each level with progress
      Map<String, dynamic> newPredictions = {};
      for (var entry in userProgress.entries) {
        if (entry.value != null) {
          final prediction = await ProgressService.getPrediction(
            entry.value['grade'] as double,
            entry.value['timeTaken'] as double,
          );
          newPredictions[entry.key] = prediction;
        }
      }

      // Get level access status using latest metrics
      final accessStatus = await ENVConfig.getLevelAccessStatus(
        metrics['grade'] ?? 0.0,
        metrics['timeTaken'] ?? 0.0,
      );

      if (mounted) {
        setState(() {
          progress = userProgress;
          predictions = newPredictions;
          levelAccess = accessStatus;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _navigateToLevel(
      BuildContext context, Map<String, dynamic> level, int levelNumber) {
    Navigator.pushNamed(
      context,
      '/level',
      arguments: {
        'level': level,
        'levelNumber': levelNumber,
        'isUnlocked': levelAccess[levelNumber] ?? false,
        'prediction': predictions[levelNumber.toString()],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Levels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _loadData();
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ENVConfig.levels.length,
        itemBuilder: (context, index) {
          final level = ENVConfig.levels[index];
          final levelNumber = index + 1;
          final isUnlocked = levelAccess[levelNumber] ?? false;
          final levelProgress = progress[levelNumber.toString()];
          final prediction = predictions[levelNumber.toString()];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LevelCard(
              level: level,
              isUnlocked: isUnlocked,
              onTap: () => _navigateToLevel(context, level, levelNumber),
              progress: levelProgress != null
                  ? {
                      'grade': levelProgress['grade'] as double,
                      'timeTaken': levelProgress['timeTaken'] as double,
                      'completedAt': DateTime.parse(
                          levelProgress['completedAt'] as String),
                      'prediction': prediction,
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
