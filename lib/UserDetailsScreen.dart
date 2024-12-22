import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId; // Le userId du couple passé depuis la page d'inscription

  const UserDetailsScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController maleNameController = TextEditingController();
  final TextEditingController femaleNameController = TextEditingController();
  final TextEditingController maleAgeController = TextEditingController();
  final TextEditingController femaleAgeController = TextEditingController();

  bool isLoading = false;

  Future<void> _saveUserDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Mettre à jour le document Firestore existant avec les nouvelles données
      await _firestore.collection('users').doc(widget.userId).update({
        'maleName': maleNameController.text,
        'femaleName': femaleNameController.text,
        'maleAge': int.tryParse(maleAgeController.text) ?? 0,
        'femaleAge': int.tryParse(femaleAgeController.text) ?? 0,
      });

      // Navigation vers la page principale ou un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Détails enregistrés avec succès")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entrer les détails du couple"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: maleNameController,
                labelText: "Nom de l'homme",
                icon: Icons.person,
              ),
              _buildTextField(
                controller: femaleNameController,
                labelText: "Nom de la femme",
                icon: Icons.person_outline,
              ),
              _buildTextField(
                controller: maleAgeController,
                labelText: "Âge de l'homme",
                icon: Icons.cake,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: femaleAgeController,
                labelText: "Âge de la femme",
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserDetails,
                child: const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
    );
  }
}
