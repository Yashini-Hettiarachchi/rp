import 'package:flutter/material.dart';
import '../constants/env.dart';
import '../widgets/level_card.dart';
import '../services/progress_service.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({Key? key}) : super(key: key);

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  Map<int, bool> levelAccess = {};
  Map<String, dynamic> progress = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load progress data
    final userProgress = await ProgressService.getProgress();
    final metrics = await ProgressService.getLatestMetrics();

    // Get level access status using latest metrics
    final accessStatus = await ENVConfig.getLevelAccessStatus(
      metrics['grade'] ?? 0.0,
      metrics['timeTaken'] ?? 0.0,
    );

    setState(() {
      progress = userProgress;
      levelAccess = accessStatus;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LevelCard(
              level: level,
              isUnlocked: isUnlocked,
              onTap: () {
                // TODO: Navigate to the level screen
                print('Level $levelNumber tapped');
              },
              progress: levelProgress != null
                  ? {
                      'grade': levelProgress['grade'] as double,
                      'timeTaken': levelProgress['timeTaken'] as double,
                      'completedAt': DateTime.parse(levelProgress['completedAt'] as String),
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
