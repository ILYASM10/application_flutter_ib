import 'package:application_couple_2/FirestoreService.dart';
import 'package:application_couple_2/MyApp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Appeler addUsers avant de lancer l'application
   //await FirestoreService().addUsers(); // Assurez-vous que cette fonction est dans votre classe.
  // Run the app
 // runApp(MyApp(FirestoreService()));
  runApp(MyApp());
}
