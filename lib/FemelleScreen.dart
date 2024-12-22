import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main_page.dart';

class FemaleInfoScreen extends StatefulWidget {
  final String email;
  final String password;
  final String maleName;
  final int maleAge;

  FemaleInfoScreen({
    required this.email,
    required this.password,
    required this.maleName,
    required this.maleAge,
  });

  @override
  _FemaleInfoScreenState createState() => _FemaleInfoScreenState();
}

class _FemaleInfoScreenState extends State<FemaleInfoScreen> {
  String femaleName = '';
  int femaleAge = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _register() async {
    if (femaleName.isEmpty || femaleAge == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    try {
      String docId = _firestore.collection('users').doc().id;

      await _firestore.collection('users').doc(docId).set({
        'userId': docId,
        'email': widget.email,
        'password': widget.password,
        'maleName': widget.maleName,
        'femaleName': femaleName,
        'maleAge': widget.maleAge,
        'femaleAge': femaleAge,
        'themes': {
          'Relation familiale et amis': {'percentage': 0, 'maleResponses': [], 'femaleResponses': [], 'questionResults': []},
          'Gestion financière': {'percentage': 0, 'maleResponses': [], 'femaleResponses': [], 'questionResults': []},
          'Éducation des enfants': {'percentage': 0, 'maleResponses': [], 'femaleResponses': [], 'questionResults': []},
          'Intimité et sexualité': {'percentage': 0, 'maleResponses': [], 'femaleResponses': [], 'questionResults': []},
          'Santé et bien-être': {'percentage': 0, 'maleResponses': [], 'femaleResponses': [], 'questionResults': []},
          'Mode de vie': {'percentage': 0, 'maleResponses': [], 'femaleResponses': [], 'questionResults': []},
        },
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(
            userId: docId,
            maleName: widget.maleName,
            maleAge: widget.maleAge,
            femaleName: femaleName,
            femaleAge: femaleAge,
          ),
        ),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'enregistrement")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations de la Femme'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.pinkAccent,
              child: Icon(
                Icons.female,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              'Nom de la Femme',
                  (value) {
                setState(() {
                  femaleName = value;
                });
              },
            ),
            _buildTextField(
              'Âge de la Femme',
                  (value) {
                setState(() {
                  femaleAge = int.tryParse(value) ?? 0;
                });
              },
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.pinkAccent,
                elevation: 3,
              ),
              child: const Text(
                'S\'inscrire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.pinkAccent),
          hintText: 'Entrez $labelText',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.pink[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.pinkAccent),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
