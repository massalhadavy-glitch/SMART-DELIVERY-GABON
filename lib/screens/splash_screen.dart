import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/auth_notifier.dart';
import 'landing_page.dart';
import 'main_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Contrôleurs d'animation
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;
  late AnimationController _bikeController; // Contrôleur pour l'animation du vélo
  
  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _progressValue;
  late Animation<double> _pulseScale;
  late Animation<double> _rotateValue;
  late Animation<double> _shimmerValue;
  late Animation<Offset> _bikeSlide; // Animation de défilement du vélo de gauche à droite

  @override
  void initState() {
    super.initState();

    // Animation du logo (zoom + fade)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );
    
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    // Animation du texte (slide + fade)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Animation de progression
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation de pulsation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation de rotation
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _rotateValue = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      _rotateController,
    );

    // Animation de brillance (shimmer)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _shimmerValue = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation du vélo qui défile de gauche à droite
    _bikeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _bikeSlide = Tween<Offset>(
      begin: const Offset(-2.0, 0.0), // Commence hors écran à gauche
      end: Offset.zero, // Se centre
    ).animate(
      CurvedAnimation(
        parent: _bikeController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Démarrer les animations
    _startAnimations();

    // Vérifie l'état de connexion
    _checkAuthStatus();
  }

  void _startAnimations() async {
    // Démarrer l'animation du vélo immédiatement (de gauche à droite)
    _bikeController.forward();
    
    // Démarrer l'animation du logo (fade/scale) après le début du vélo
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _logoController.forward();
    
    // Démarrer l'animation du texte après 700ms
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _textController.forward();
    
    // Démarrer l'animation de progression après 800ms
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _progressController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    _bikeController.dispose();
    super.dispose();
  }

  void _checkAuthStatus() async {
    // Attendre que les animations se lancent (3 secondes pour laisser plus de temps)
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    if (authNotifier.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainWrapper()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LandingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a237e), // Bleu foncé
              const Color(0xFF0d47a1), // Bleu
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.8),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Particules animées en arrière-plan
            ...List.generate(20, (index) => _buildParticle(size, index)),
            
            // Cercles décoratifs animés
            _buildDecorativeCircles(size),
            
            // Contenu principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Vélo animé qui défile de gauche à droite puis se centre
                  SlideTransition(
                    position: _bikeSlide,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Container(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          'assets/images/delivery_bike.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Texte animé avec effet shimmer
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          // Titre principal avec effet de brillance
                          AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: const [
                                      Colors.white,
                                      Color(0xFFE3F2FD),
                                      Colors.white,
                                      Color(0xFFE3F2FD),
                                      Colors.white,
                                    ],
                                    stops: [
                                      0.0,
                                      0.4 + (_shimmerValue.value * 0.1),
                                      0.5 + (_shimmerValue.value * 0.1),
                                      0.6 + (_shimmerValue.value * 0.1),
                                      1.0,
                                    ],
                                  ).createShader(bounds);
                                },
                                child: const Text(
                                  'SMART DELIVERY',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 3.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Sous-titre
                          Text(
                            'GABON',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 8.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Slogan
                          Text(
                            'Livraison Express & Sécurisée',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Barre de progression animée
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Column(
                        children: [
                          // Barre de progression personnalisée
                          Container(
                            width: 200,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: 200 * _progressValue.value,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.white.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Texte de chargement
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: 0.5 + (_pulseScale.value - 1.0) * 5,
                                child: Text(
                                  'Chargement...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Version en bas
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textFade,
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Particules flottantes animées
  Widget _buildParticle(Size size, int index) {
    final random = math.Random(index);
    final startX = random.nextDouble() * size.width;
    final startY = random.nextDouble() * size.height;
    final duration = 3000 + random.nextInt(2000);
    final delay = random.nextInt(1000);
    final particleSize = 2.0 + random.nextDouble() * 4;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: duration),
      builder: (context, value, child) {
        return Positioned(
          left: startX + (math.sin(value * 2 * math.pi) * 50),
          top: startY - (value * size.height * 0.3),
          child: Opacity(
            opacity: (1 - value).clamp(0.0, 0.6),
            child: Container(
              width: particleSize,
              height: particleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Redémarrer l'animation
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  // Cercles décoratifs en arrière-plan
  Widget _buildDecorativeCircles(Size size) {
    return Stack(
      children: [
        // Grand cercle en haut à gauche
        Positioned(
          top: -100,
          left: -100,
          child: AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateValue.value * 0.5,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Cercle moyen en bas à droite
        Positioned(
          bottom: -80,
          right: -80,
          child: AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_rotateValue.value * 0.3,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}