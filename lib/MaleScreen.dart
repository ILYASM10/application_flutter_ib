import 'package:flutter/material.dart';

import 'FemelleScreen.dart';

class MaleInfoScreen extends StatefulWidget {
  final String email;
  final String password;

  MaleInfoScreen({required this.email, required this.password});

  @override
  _MaleInfoScreenState createState() => _MaleInfoScreenState();
}

class _MaleInfoScreenState extends State<MaleInfoScreen> {
  String maleName = '';
  int maleAge = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Informations de l\'Homme',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B8DFF), Color(0xFF73C2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue[300],
                  child: Icon(
                    Icons.male,
                    color: Colors.white,
                    size: 70,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.blue[900]!,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  'Nom de l\'Homme',
                      (value) {
                    setState(() {
                      maleName = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Âge de l\'Homme',
                      (value) {
                    setState(() {
                      maleAge = int.tryParse(value) ?? 0;
                    });
                  },
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (maleName.isNotEmpty && maleAge > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FemaleInfoScreen(
                            email: widget.email,
                            password: widget.password,
                            maleName: maleName,
                            maleAge: maleAge,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez remplir tous les champs')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Suivant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        hintText: 'Entrez $labelText',
        hintStyle: TextStyle(color: Colors.blue[200]),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto, // Affichage dynamique
      ),
      onChanged: onChanged,
    );
  }
}
