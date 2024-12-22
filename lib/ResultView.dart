import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultView extends StatefulWidget {
  final String docId; // Unique user ID from Firestore
  final String theme;
  final double compatibilityPercentage;
  final Color themeColor;
  final List questions; // List of questions
  final List<String> questionResults; // List of results (match, neutral, contradictory)
  final List<Map<String, dynamic>> maleResponses; // Updated to match response structure
  final List<Map<String, dynamic>> femaleResponses; // Updated to match response structure
  final String maleName; // Male's name
  final String femaleName; // Female's name

  ResultView({
    required this.docId,
    required this.theme,
    required this.compatibilityPercentage,
    required this.themeColor,
    required this.questions, // Pass the questions list
    required this.questionResults, // Pass the results list
    required this.maleResponses, // Pass male responses
    required this.femaleResponses, // Pass female responses
    required this.maleName, // Pass male name
    required this.femaleName, // Pass female name
  });

  @override
  _ResultViewState createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  String filter = 'all'; // Default filter shows all questions
  bool showResponses = false; // Track if responses are shown

  // Method to update Firestore with the compatibility percentage for the specific theme
  Future<void> _updateUserThemeProgress() async {
    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users')
          .doc(widget.docId);

      await userDoc.update({
      });
      print("Theme progress updated successfully!");
    } catch (e) {
      print("Error updating theme progress: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _updateUserThemeProgress(); // Call Firestore update when the widget builds
  }

  @override
  Widget build(BuildContext context) {
    List filteredQuestions = [];
    List<String> filteredResults = [];

    // Apply the selected filter
    if (filter == 'all') {
      filteredQuestions = widget.questions;
      filteredResults = widget.questionResults;
    } else {
      for (int i = 0; i < widget.questionResults.length; i++) {
        if (widget.questionResults[i] == filter) {
          filteredQuestions.add(widget.questions[i]);
          filteredResults.add(widget.questionResults[i]);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Résultat - ${widget.theme}'),
        backgroundColor: widget.themeColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildFilterButtons(),
            SizedBox(height: 20),
            _buildToggleResponsesButton(),
            SizedBox(height: 20),
            _buildQuestionsList(filteredQuestions, filteredResults),
          ],
        ),
      ),
    );
  }

  // Builds the header with theme information and compatibility circle
  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            'Thème: ${widget.theme}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.themeColor,
            ),
          ),
          SizedBox(height: 30),
          // Compatibility Circle with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
                begin: 0, end: widget.compatibilityPercentage / 100),
            duration: Duration(seconds: 2),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          widget.themeColor),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${(value * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: widget.themeColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Compatibilité',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Builds filter buttons
  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['all', 'match', 'neutral', 'contradictory']
            .map((String filterType) => _buildFilterButton(filterType))
            .toList(),
      ),
    );
  }

  // Creates a filter button
  Widget _buildFilterButton(String filterType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: filter == filterType ? widget.themeColor : Colors
              .grey[300],
        ),
        onPressed: () {
          setState(() {
            filter = filterType;
          });
        },
        child: Text(
          _getFilterButtonText(filterType),
          style: TextStyle(
              color: filter == filterType ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // Returns the button text based on the filter type
  String _getFilterButtonText(String filterType) {
    switch (filterType) {
      case 'match':
        return 'Compatible';
      case 'neutral':
        return 'Neutre';
      case 'contradictory':
        return 'Contre';
      default:
        return 'Tout';
    }
  }

  // Builds the toggle responses button
  Widget _buildToggleResponsesButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.themeColor,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      ),
      onPressed: () {
        setState(() {
          showResponses = !showResponses; // Toggle response visibility
        });
      },
      child: Text(
        showResponses ? 'Cacher les réponses' : 'Afficher les réponses',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildQuestionsList(List filteredQuestions, List<String> filteredResults) {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredQuestions.isEmpty ? 1 : filteredQuestions.length,
        itemBuilder: (context, index) {
          if (filteredQuestions.isEmpty || filteredResults.isEmpty) {
            return Center(child: Text("Aucune question à afficher."));
          }

          // Access result safely since we know the filtered lists are not empty
          String result = filteredResults[index];
          IconData icon;
          Color iconColor;

          // Define the icon and color based on the result
          switch (result) {
            case "match":
              icon = Icons.check_circle;
              iconColor = Colors.green;
              break;
            case "neutral":
              icon = Icons.remove_circle;
              iconColor = Colors.orange;
              break;
            default:
              icon = Icons.cancel;
              iconColor = Colors.red;
              break;
          }

          // Get the question from the filtered questions list
          var question = filteredQuestions[index];

          // Retrieve response texts directly from the attributes of ResultView
          String maleResponseText = index < widget.maleResponses.length
              ? widget.maleResponses[index]['text']
              : 'Non spécifié';

          String femaleResponseText = index < widget.femaleResponses.length
              ? widget.femaleResponses[index]['text']
              : 'Non spécifié';

          return _buildQuestionCard(
            question['question_text'],
            maleResponseText,
            femaleResponseText,
            icon,
            iconColor,
          );
        },
      ),
    );
  }


// Builds a question card
  Widget _buildQuestionCard(String questionText, String maleResponse, String femaleResponse, IconData icon, Color iconColor) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(questionText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  if (showResponses) ...[
                    Text("Réponse de ${widget.maleName}: $maleResponse", style: TextStyle(color: Colors.blue)),
                    Text("Réponse de ${widget.femaleName}: $femaleResponse", style: TextStyle(color: Colors.pink)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
