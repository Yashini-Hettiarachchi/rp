import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LevelCard extends StatefulWidget {
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
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard> {
  bool isLoadingPrediction = false;
  Map<String, dynamic>? predictionData;

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _fetchPrediction() async {
    if (widget.progress == null) return;

    setState(() {
      isLoadingPrediction = true;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
                '${ENVConfig.predictionUrl}?grade=${widget.progress!['grade']}&time_taken=${widget.progress!['timeTaken']}'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          predictionData = data;
          isLoadingPrediction = false;
        });
      } else {
        setState(() {
          predictionData = null;
          isLoadingPrediction = false;
        });
      }
    } catch (e) {
      setState(() {
        predictionData = null;
        isLoadingPrediction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = widget.level['color'] as Color;
    final String backgroundImage = widget.level['background'] as String? ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor.withOpacity(0.8),
              cardColor.withOpacity(0.6),
            ],
          ),
        ),
        child: InkWell(
          onTap: widget.isUnlocked ? widget.onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.level['title'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.level['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isUnlocked)
                      const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 24,
                      ),
                  ],
                ),
                if (widget.progress != null) ...[
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Performance Analysis:',
                              style: TextStyle(
                                color: widget.isUnlocked
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.analytics,
                                  color: Colors.white),
                              onPressed: () async {
                                await _fetchPrediction();
                                if (!mounted) return;

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Performance Analysis'),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: isLoadingPrediction
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : predictionData == null
                                              ? const Center(
                                                  child: Text(
                                                      'Unable to fetch analysis'))
                                              : Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildAnalysisItem(
                                                      'Current Grade',
                                                      '${widget.progress!['grade'].toStringAsFixed(1)}%',
                                                      Icons.grade,
                                                    ),
                                                    _buildAnalysisItem(
                                                      'Time Taken',
                                                      '${widget.progress!['timeTaken'].toStringAsFixed(1)}s',
                                                      Icons.timer,
                                                    ),
                                                    const Divider(),
                                                    _buildAnalysisItem(
                                                      'Performance Adjustment',
                                                      '${predictionData!['adjustment'].toStringAsFixed(1)}',
                                                      Icons.trending_up,
                                                      color: predictionData![
                                                                  'adjustment'] >
                                                              0
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        predictionData![
                                                                    'adjustment'] >
                                                                0
                                                            ? 'Great progress! Keep up the good work!'
                                                            : 'Keep practicing to improve your performance!',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Grade: ${(widget.progress!['grade'] as double).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: widget.isUnlocked
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Time: ${(widget.progress!['timeTaken'] as double).toStringAsFixed(1)}s',
                          style: TextStyle(
                            color: widget.isUnlocked
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Completed: ${_formatDate(widget.progress!['completedAt'] as DateTime)}',
                          style: TextStyle(
                            color: widget.isUnlocked
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.blue),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
