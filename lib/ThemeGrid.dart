import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'QuestionView.dart';
import 'ResultView.dart';
import 'FirestoreService.dart';

class ThemeGrid extends StatefulWidget {
  final String userId;
  final String maleName;
  final String femaleName;

  ThemeGrid({
    required this.userId,
    required this.maleName,
    required this.femaleName,
  });

  @override
  _ThemeGridState createState() => _ThemeGridState();
}

class _ThemeGridState extends State<ThemeGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Color> vibrantColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
  ];

  final Map<String, IconData> themeIcons = {
    'Finance': Icons.monetization_on,
    'Relation': Icons.favorite,
    'Maison': Icons.home,
    'Sexe': Icons.bed,
    'Santé': Icons.health_and_safety,
    'Mode de vie': Icons.pets,
    'Enfant': Icons.child_care,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thèmes"),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: FirestoreService().getQuestions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final questions = snapshot.data!;
                Map<String, List<Map<String, dynamic>>> categorizedQuestions = categorizeQuestions(questions);

                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: FirestoreService().getUserResponsesAndResults(widget.userId),
                    builder: (context, responsesSnapshot) {
                      if (responsesSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (responsesSnapshot.hasError) {
                        return Center(child: Text('Erreur: ${responsesSnapshot.error}'));
                      } else if (responsesSnapshot.hasData) {
                        final userResponsesAndResults = responsesSnapshot.data!;
                        final themes = userResponsesAndResults['themes'] as Map<String, dynamic>? ?? {};

                        return GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          childAspectRatio: 1.0,
                          children: categorizedQuestions.keys.map((category) {
                            final themeQuestions = categorizedQuestions[category]!;
                            final femaleResponses = (themes[category]?['femaleResponses'] as List<dynamic>? ?? [])
                                .where((response) => response != null) // Filter out any null responses
                                .map((response) => Map<String, dynamic>.from(response))
                                .toList();

                            final maleResponses = (themes[category]?['maleResponses'] as List<dynamic>? ?? [])
                                .where((response) => response != null) // Filter out any null responses
                                .map((response) => Map<String, dynamic>.from(response))
                                .toList();


                            final questionResults = (themes[category]?['questionResults'] as List<dynamic>? ?? [])
                                .map((result) => result.toString()).toList();

                            final femaleResponsesMapped = femaleResponses.map((response) => {'text': response}).toList();
                            final maleResponsesMapped = maleResponses.map((response) => {'text': response}).toList();
                            return FutureBuilder<double>(
                              future: FirestoreService().getCompatibilityPercentage(widget.userId, category),
                              builder: (context, percentageSnapshot) {
                                if (percentageSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (percentageSnapshot.hasError) {
                                  return Center(child: Text('Erreur: ${percentageSnapshot.error}'));
                                } else {
                                  final compatibilityPercentage = percentageSnapshot.data ?? 0.0;
                                  final clampedPercentage = compatibilityPercentage.clamp(0.0, 100.0);
                                  int colorIndex = categorizedQuestions.keys.toList().indexOf(category) % vibrantColors.length;
                                  Color cardColor = vibrantColors[colorIndex];
                                  HSLColor hslColor = HSLColor.fromColor(cardColor);
                                  Color darkCardColor = hslColor.withLightness(0.05).toColor();

                                  return buildThemeCard(
                                    context,
                                    category,
                                    clampedPercentage,
                                    themeQuestions,
                                    cardColor,
                                    darkCardColor,
                                    femaleResponses,
                                    maleResponses,
                                    questionResults,
                                  );
                                }
                              },
                            );
                          }).toList(),
                        );
                      } else {
                        return Center(child: Text('Aucune réponse trouvée'));
                      }
                    },
                  ),
                );
              } else {
                return Center(child: Text('Aucune question trouvée'));
              }
            },
          ),
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> categorizeQuestions(List<Map<String, dynamic>> questions) {
    Map<String, List<Map<String, dynamic>>> categorized = {};
    for (var question in questions) {
      String category = question['category'] ?? 'Unknown';
      categorized.putIfAbsent(category, () => []).add(question);
    }
    return categorized;
  }

  Widget buildThemeCard(
      BuildContext context,
      String title,
      double percentage,
      List<Map<String, dynamic>> questions,
      Color cardColor,
      Color darkCardColor,
      List<Map<String, dynamic>> femaleResponses, // Update to List<Map<String, dynamic>>
      List<Map<String, dynamic>> maleResponses,   // Update to List<Map<String, dynamic>>
      List<String> questionResults, // No change needed here
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: cardColor,
      child: InkWell(
        onTap: () async {
          if (percentage > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultView(
                  theme: title,
                  docId: widget.userId,
                  questions: questions,
                  femaleName: widget.femaleName,
                  maleName: widget.maleName,
                  femaleResponses: femaleResponses, // Pass as List<Map<String, dynamic>>
                  maleResponses: maleResponses,     // Pass as List<Map<String, dynamic>>
                  questionResults: questionResults,
                  compatibilityPercentage: percentage,
                  themeColor: cardColor,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionView(
                  theme: title,
                  userId: widget.userId,
                  maleName: widget.maleName,
                  femaleName: widget.femaleName,
                  questions: questions,
                  themeColor: cardColor,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                themeIcons[title] ?? Icons.help,
                size: 40,
                color: Colors.white,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              if (percentage > 0) ...[
                CircularPercentIndicator(
                  radius: 25.0,
                  lineWidth: 3.0,
                  animation: true,
                  animationDuration: 1000,
                  percent: percentage / 100,
                  center: Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(color: Colors.white),
                  ),
                  progressColor: Colors.yellowAccent,
                  backgroundColor: darkCardColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
