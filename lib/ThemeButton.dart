import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeButton extends StatefulWidget {
  final String label;            // Label du bouton
  final Color borderColor;       // Couleur de la bordure
  final Color textColor;         // Couleur du texte
  final Color buttonColor;       // Couleur du bouton
  final VoidCallback onTap;      // Fonction à exécuter lors de l'appui

  ThemeButton({
    required this.label,
    required this.borderColor,
    required this.textColor,
    required this.buttonColor,   // Ajout de la couleur personnalisée du bouton
    required this.onTap,
  });

  @override
  _ThemeButtonState createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<ThemeButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false; // Indique si le bouton est enfoncé

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true), // Détecter la pression sur le bouton
      onTapUp: (_) {
        _setPressed(false); // Relâcher la pression
        widget.onTap(); // Exécuter l'action associée
      },
      onTapCancel: () => _setPressed(false), // Réinitialiser si l'utilisateur annule l'appui
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150), // Animation plus douce
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0), // Réduire légèrement la taille lors de l'appui
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: _isPressed ? widget.buttonColor.withOpacity(0.7) : widget.buttonColor, // Utilisation de la couleur personnalisée
          border: Border.all(color: widget.borderColor, width: 2), // Contour du bouton
          borderRadius: BorderRadius.circular(12.0), // Coins arrondis
          boxShadow: _isPressed
              ? [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))] // Ombre renforcée quand enfoncé
              : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))], // Ombre normale
        ),
        child: Center(
          child: Text(
            widget.label, // Texte du bouton
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18, // Taille de police
              color: widget.textColor, // Couleur du texte
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _setPressed(bool isPressed) {
    setState(() {
      _isPressed = isPressed; // Met à jour l'état visuel lors de l'appui ou du relâchement
    });
  }
}
