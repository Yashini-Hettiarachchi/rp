import 'package:flutter/material.dart';
import '../constants/env.dart';

class LevelCard extends StatelessWidget {
  final Map<String, dynamic> level;
  final bool isUnlocked;
  final VoidCallback onTap;
  final Map<String, dynamic>? progress;

  const LevelCard({
    Key? key,
    required this.level,
    required this.isUnlocked,
    required this.onTap,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isUnlocked ? 4 : 2,
      color: isUnlocked ? level['color'] : Colors.grey[300],
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      level['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (!isUnlocked)
                    const Icon(
                      Icons.lock,
                      color: Colors.grey,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                level['description'],
                style: TextStyle(
                  color: isUnlocked ? Colors.white70 : Colors.grey[600],
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Attempt:',
                        style: TextStyle(
                          color: isUnlocked ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Grade: ${(progress!['grade'] as double).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isUnlocked ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Time: ${(progress!['timeTaken'] as double).toStringAsFixed(1)}s',
                        style: TextStyle(
                          color: isUnlocked ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Completed: ${_formatDate(progress!['completedAt'] as DateTime)}',
                        style: TextStyle(
                          color: isUnlocked ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!isUnlocked)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Complete previous levels to unlock',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
