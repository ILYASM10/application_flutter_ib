import 'package:application_couple_2/Auth.dart';
import 'package:application_couple_2/FirestoreService.dart';
import 'package:application_couple_2/MyApp.dart';
import 'package:application_couple_2/RegistrationScreen.dart'; // Importez RegistrationScreen

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Couple',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthScreen(), // Set RegistrationScreen as the initial screen
    );
  }
}
