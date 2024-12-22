import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'MaleScreen.dart';
import 'main_page.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // Basculer entre login et inscription
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }
  void loginAndNavigate(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      // Récupérer les utilisateurs depuis Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users') // Remplacez par le nom de votre collection
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Identifiants incorrects')),
        );
        return;
      }

      // Extraire les données de l'utilisateur trouvé
      final userData = querySnapshot.docs.first.data();
      final userId = querySnapshot.docs.first.id;
      final maleName = userData['maleName'] ?? 'Nom de l\'homme';
      final femaleName = userData['femaleName'] ?? 'Nom de la femme';
      final maleAge = userData['maleAge'] ?? 30;
      final femaleAge = userData['femaleAge'] ?? 28;

      // Naviguer vers l'écran principal
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(
            userId: userId,
            maleName: maleName,
            femaleName: femaleName,
            maleAge: maleAge,
            femaleAge: femaleAge,
          ),
        ),
      );
    } catch (error) {
      print('Erreur de connexion : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la connexion')),
      );
    }
  }

  void navigateToMaleScreen(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaleInfoScreen(email: email, password: password),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dégradé en arrière-plan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[300]!, Colors.blue[800]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Contenu principal
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo ou titre principal
                    Text(
                      'Bienvenue',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isLogin ? 'Connectez-vous à votre compte' : 'Créez un nouveau compte',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Formulaire
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Email',
                              prefixIcon: const Icon(CupertinoIcons.mail_solid),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Veuillez entrer un email';
                              } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Entrez un email valide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Mot de passe
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(CupertinoIcons.lock_fill),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? CupertinoIcons.eye_fill
                                      : CupertinoIcons.eye_slash_fill,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Veuillez entrer un mot de passe';
                              } else if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                          if (!isLogin) ...[
                            const SizedBox(height: 20),
                            // Confirmation mot de passe
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: obscurePassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Confirmer le mot de passe',
                                prefixIcon: const Icon(CupertinoIcons.lock_fill),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return 'Les mots de passe ne correspondent pas';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 30),
                          // Bouton principal
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (isLogin) {
                                  loginAndNavigate(context); // Appel à la méthode pour se connecter
                                } else {
                                  navigateToMaleScreen(context); // Redirection vers l'inscription
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.blue[900],
                            ),
                            child: Text(
                              isLogin ? 'Se connecter' : 'S\'inscrire',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),
                          // Texte pour basculer entre connexion/inscription
                          TextButton(
                            onPressed: toggleAuthMode,
                            child: Text(
                              isLogin
                                  ? 'Pas encore de compte ? Inscrivez-vous'
                                  : 'Déjà un compte ? Connectez-vous',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}