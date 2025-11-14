import 'package:flutter/material.dart';
import 'login_page.dart';
import 'main_wrapper.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Bienvenue sur Smart Delivery Gabon",
      description: "Votre partenaire de livraison rapide et fiable au Gabon",
      icon: Icons.local_shipping_rounded,
      color: Colors.blue,
    ),
    OnboardingData(
      title: "Livraison Express",
      description: "Recevez vos colis en moins de 30 minutes dans Libreville",
      icon: Icons.flash_on_rounded,
      color: Colors.green,
    ),
    OnboardingData(
      title: "Suivi en Temps Réel",
      description: "Suivez votre livraison en direct avec notre système de géolocalisation",
      icon: Icons.gps_fixed_rounded,
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // PageView pour les slides
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingSlide(_onboardingData[index]);
                },
              ),
            ),
            
            // Indicateurs de page et boutons
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Points indicateurs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Bouton suivant ou commencer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_currentPage < _onboardingData.length - 1) {
                            // Aller à la page suivante
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            // Dernière page, commencer l'application
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const MainWrapper()),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage < _onboardingData.length - 1 
                                  ? 'Suivant' 
                                  : 'Commencer',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage < _onboardingData.length - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.check_circle_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Icône admin discrète
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.grey[700]!, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white70,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Accès Admin',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingSlide(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône avec design amélioré
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data.color.withOpacity(0.3),
                  data.color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: data.color.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 90,
            ),
          ),
          
          const SizedBox(height: 50),
          
          // Titre
          Text(
            data.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              data.description,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
