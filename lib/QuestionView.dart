import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ResultView.dart';

class QuestionView extends StatefulWidget {
  final String theme;
  final List questions;
  final String userId;
  final String maleName;
  final String femaleName;
  final Color themeColor;

  QuestionView({
    required this.theme,
    required this.questions,
    required this.userId,
    required this.maleName,
    required this.femaleName,
    required this.themeColor,
  });

  @override
  _QuestionViewState createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  int currentQuestionIndex = 0;
  bool isMaleTurn = true;
  List<Map<String, dynamic>> maleResponses = [];
  List<Map<String, dynamic>> femaleResponses = [];
  List<String> questionResults = [];
  bool isMaleAnswered = false;
  bool isFemaleAnswered = false;

  // Variable pour stocker le pourcentage de compatibilité
  double compatibilityPercentage = 0.0;

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[currentQuestionIndex];
    final totalQuestions = widget.questions.length;

    // Texte qui change dynamiquement en fonction du tour
    String turnText = isMaleTurn
        ? "C'est au tour de ${widget.maleName}"
        : "C'est au tour de ${widget.femaleName}";

    return Scaffold(
      backgroundColor: widget.themeColor.withOpacity(0.2),
      appBar: AppBar(
        title: Text(widget.theme),
        backgroundColor: widget.themeColor.withOpacity(0.9),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              turnText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.themeColor.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Question ${currentQuestionIndex + 1}/$totalQuestions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.themeColor.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 20),
            _buildQuestionCard(currentQuestion),
            SizedBox(height: 20),
            _buildResponseButtons(currentQuestion),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire la carte de la question
  Widget _buildQuestionCard(Map<String, dynamic> currentQuestion) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        currentQuestion['question_text'] ?? 'Question sans texte',
        style: TextStyle(fontSize: 18, color: widget.themeColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Méthode pour construire les boutons de réponses
  Widget _buildResponseButtons(Map<String, dynamic> currentQuestion) {
    return Column(
      children: (currentQuestion['reponses'] as List<dynamic>?)?.map<Widget>((reponse) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleResponse(reponse),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(reponse['texte'] ?? 'Texte sans réponse'), // Texte par défaut si null
          ),
        );
      }).toList() ?? [],
    );
  }

  // Méthode pour construire les boutons de navigation
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentQuestionIndex > 0)
          IconButton(
            icon: Icon(Icons.arrow_back, color: widget.themeColor),
            onPressed: _previousQuestion,
            iconSize: 30,
          ),
        if (currentQuestionIndex < widget.questions.length - 1)
          IconButton(
            icon: Icon(Icons.arrow_forward, color: widget.themeColor),
            onPressed: _nextQuestion,
            iconSize: 30,
          ),
      ],
    );
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        isMaleTurn = !isMaleTurn;
        isMaleAnswered = false;
        isFemaleAnswered = false;
      });
    }
  }

  void _handleResponse(Map<String, dynamic> reponse) {
    String responseText = reponse['texte'];
    int responsePoints = (reponse['points'] as num).toInt();

    if (isMaleTurn) {
      maleResponses.add({'text': responseText, 'points': responsePoints});
      isMaleAnswered = true;
    } else {
      femaleResponses.add({'text': responseText, 'points': responsePoints});
      isFemaleAnswered = true;
    }

    if (isMaleAnswered && isFemaleAnswered) {
      _categorizeQuestion(currentQuestionIndex);
      _nextQuestion();
    } else {
      setState(() {
        isMaleTurn = !isMaleTurn; // Change dynamiquement le tour
      });
    }
  }

  void _categorizeQuestion(int index) {
    if (index < maleResponses.length && index < femaleResponses.length) {
      int malePoints = maleResponses[index]['points'];
      int femalePoints = femaleResponses[index]['points'];
      int difference = (malePoints - femalePoints).abs();

      if (difference == 0) {
        questionResults.add("match");
      } else if (difference <= 2) {
        questionResults.add("neutral");
      } else {
        questionResults.add("contradictory");
      }
    }
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < widget.questions.length - 1) {
        currentQuestionIndex++;
        isMaleTurn = true;
        isMaleAnswered = false;
        isFemaleAnswered = false;
      } else {
        compatibilityPercentage = calculateCompatibility();
        _storeResponses(widget.theme);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultView(
              theme: widget.theme,
              compatibilityPercentage: compatibilityPercentage,
              themeColor: widget.themeColor,
              docId: widget.userId,
              questions: widget.questions,
              maleResponses: maleResponses,
              femaleResponses: femaleResponses,
              maleName: widget.maleName,
              femaleName: widget.femaleName,
              questionResults: questionResults,
            ),
          ),
        );
      }
    });
  }

  double calculateCompatibility() {
    int totalCompatibilityScore = 0;
    int totalQuestions = maleResponses.length;

    for (int i = 0; i < totalQuestions; i++) {
      int malePoints = maleResponses[i]['points'];
      int femalePoints = femaleResponses[i]['points'];
      int difference = (malePoints - femalePoints).abs();

      int questionScore = difference == 0
          ? 6
          : (difference == 2 ? 4 : 2);

      totalCompatibilityScore += questionScore;
    }

    return (totalCompatibilityScore / (totalQuestions * 6)) * 100;
  }

  void _storeResponses(String themeName) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);

    userDoc.update({
      'themes.$themeName.maleResponses': maleResponses,
      'themes.$themeName.femaleResponses': femaleResponses,
      'themes.$themeName.percentage': compatibilityPercentage,
      'themes.$themeName.questionResults': questionResults,
    }).catchError((error) {
      print("Erreur lors de la sauvegarde: $error");
    });
  }
}
