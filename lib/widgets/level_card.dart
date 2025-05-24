import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<dynamic> previousRecords = [];
  bool isLoadingRecords = false;

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _fetchPreviousRecords() async {
    setState(() {
      isLoadingRecords = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('authEmployeeID') ?? "sampleUser";

      final response = await http
          .get(
            Uri.parse(
                '${ENVConfig.serverUrl}/vocabulary-records/user/$username'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          previousRecords = data['records'] ?? [];
          isLoadingRecords = false;
        });
      } else {
        setState(() {
          previousRecords = [];
          isLoadingRecords = false;
        });
      }
    } catch (e) {
      setState(() {
        previousRecords = [];
        isLoadingRecords = false;
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
                              'Activity Summary:',
                              style: TextStyle(
                                color: widget.isUnlocked
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.history,
                                  color: Colors.white),
                              onPressed: () async {
                                await _fetchPreviousRecords();
                                if (!mounted) return;

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Previous Records'),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: isLoadingRecords
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : previousRecords.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                      'No previous records found'))
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      previousRecords.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final record =
                                                        previousRecords[index];
                                                    return Card(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4),
                                                      child: ListTile(
                                                        title: Text(
                                                          record['activity'] ??
                                                              'Vocabulary Activity',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        subtitle: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                'Score: ${record['score']}%'),
                                                            Text(
                                                                'Time: ${record['time_taken']}s'),
                                                            Text(
                                                                'Date: ${_formatDate(DateTime.parse(record['recorded_date']))}'),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
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
}
