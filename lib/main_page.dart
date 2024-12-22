import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'ThemeGrid.dart';


class MainPage extends StatefulWidget {
  final String userId;
  final String maleName;
  final int maleAge;
  final String femaleName;
  final int femaleAge;

  const MainPage({
    required this.userId,
    required this.maleName,
    required this.maleAge,
    required this.femaleName,
    required this.femaleAge,
    super.key,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween(begin: 1.0, end: 1.05).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Bienvenue'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Animated background
          AnimatedBackground(),

          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 80),

                  // Animated welcome text
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Bienvenue, ${widget.maleName} et ${widget.femaleName}!',
                        textStyle: const TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    isRepeatingAnimation: false,
                  ),

                  const SizedBox(height: 10),
                  Text(
                    '${widget.maleName} (${widget.maleAge} ans) et ${widget.femaleName} (${widget.femaleAge} ans)',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  _buildAnimatedInfoCard(
                    context,
                    'Explorez les différentes thématiques de votre relation.',
                    FontAwesomeIcons.bookOpen,
                  ),
                  _buildAnimatedInfoCard(
                    context,
                    'Répondez à des questions pour découvrir votre compatibilité.',
                    FontAwesomeIcons.questionCircle,
                  ),
                  _buildAnimatedInfoCard(
                    context,
                    'Recevez un bilan personnalisé avec des graphiques animés.',
                    FontAwesomeIcons.chartPie,
                  ),

                  const SizedBox(height: 40),

                  // Animated Button
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      label: const Text('Commencer'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThemeGrid(
                              userId: widget.userId,
                              maleName: widget.maleName,
                              femaleName: widget.femaleName,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable info card with animation and icon
  Widget _buildAnimatedInfoCard(BuildContext context, String message, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            FaIcon(icon, color: Colors.teal, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: Colors.teal[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for animated background
class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: ColorTween(
        begin: Color(0xFF64B5F6), // Light blue
        end: Color(0xFF0D47A1), // Dark blue
      ),
      duration: Duration(seconds: 4),
      builder: (BuildContext context, Color? color, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [color!, Color(0xFF0D47A1)],
              radius: 1.5,
              center: Alignment(0.7, -0.6),
            ),
          ),
        );
      },
    );
  }
}
