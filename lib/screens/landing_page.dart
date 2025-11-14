import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_notifier.dart';
import 'login_page.dart';
import 'main_wrapper.dart';
import 'onboarding_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec navigation
            _buildHeader(context, theme),
            
            // Hero Section avec animation
            _buildHeroSection(context, theme, size),
            
            // Services Section
            _buildServicesSection(context, theme),
            
            // Features Section
            _buildFeaturesSection(context, theme),
            
            // Testimonials Section
            _buildTestimonialsSection(context, theme),
            
            // Stats Section
            _buildStatsSection(context, theme),
            
            // CTA Section
            _buildCTASection(context, theme),
            
            // Footer
            _buildFooter(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return const SizedBox(height: 20);
  }

  Widget _buildHeroSection(BuildContext context, ThemeData theme, Size size) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              children: [
                // Logo principal avec effet de brillance
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.2),
                        blurRadius: 50,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/smart_delivery_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Titre principal avec effet de gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.white, theme.primaryColor.withOpacity(0.8)],
                  ).createShader(bounds),
                  child: Text(
                    'Smart Delivery Gabon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width > 600 ? 42 : 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sous-titre avec animation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '⚡ Livraison Express en moins de 30 minutes',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Description
                Text(
                  'Service de livraison rapide, fiable et sécurisé dans tout Libreville. Rejoignez des milliers de clients satisfaits et découvrez la livraison du futur.',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 50),
                
                // Boutons d'action avec animations
                Column(
                  children: [
                    // Bouton principal
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainWrapper()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Commencer Maintenant',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Bouton secondaire
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.primaryColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OnboardingPage()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Découvrir nos services',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.info_outline_rounded,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context, ThemeData theme) {
    final services = [
      ServiceData(
        icon: Icons.flash_on_rounded,
        title: 'Livraison Express',
        description: 'Moins de 30 minutes dans Libreville',
        color: Colors.orange,
        features: ['Géolocalisation en temps réel', 'Notifications instantanées'],
      ),
      ServiceData(
        icon: Icons.security_rounded,
        title: 'Sécurisé',
        description: 'Protection garantie de vos colis',
        color: Colors.green,
        features: ['Assurance incluse', 'Suivi détaillé'],
      ),
      ServiceData(
        icon: Icons.support_agent_rounded,
        title: 'Support 24/7',
        description: 'Assistance disponible à tout moment',
        color: Colors.blue,
        features: ['Chat en direct', 'Résolution rapide'],
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        children: [
          Text(
            'Nos Services',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Des solutions de livraison adaptées à vos besoins',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          ...services.asMap().entries.map((entry) {
            int index = entry.key;
            ServiceData service = entry.value;
            return _buildServiceCard(service, theme, index);
          }),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceData service, ThemeData theme, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: service.color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: service.color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  service.color.withOpacity(0.2),
                  service.color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              service.icon,
              color: service.color,
              size: 32,
            ),
          ),
          
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  service.description,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ...service.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: service.color,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        feature,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        children: [
          Text(
            'Pourquoi Choisir Smart Delivery ?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 40),
          
          _buildFeatureItem(
            Icons.speed_rounded,
            'Rapidité Exceptionnelle',
            'Livraison en moins de 30 minutes grâce à notre réseau optimisé',
            Colors.red,
          ),
          
          _buildFeatureItem(
            Icons.verified_user_rounded,
            'Fiabilité Garantie',
            'Service de qualité avec suivi en temps réel et assurance incluse',
            Colors.blue,
          ),
          
          _buildFeatureItem(
            Icons.support_agent_rounded,
            'Support Premium',
            'Assistance client disponible 24h/24 avec résolution rapide',
            Colors.green,
          ),
          
          _buildFeatureItem(
            Icons.eco_rounded,
            'Écologique',
            'Livraisons optimisées pour réduire l\'impact environnemental',
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context, ThemeData theme) {
    final testimonials = [
      TestimonialData(
        name: 'Marie Nguema',
        role: 'Entrepreneuse',
        content: 'Service exceptionnel ! Mes colis arrivent toujours à l\'heure. Je recommande vivement Smart Delivery.',
        rating: 5,
      ),
      TestimonialData(
        name: 'Jean-Pierre Mba',
        role: 'Commerçant',
        content: 'La rapidité et la fiabilité de ce service ont transformé mon business. Un partenaire de confiance.',
        rating: 5,
      ),
      TestimonialData(
        name: 'Fatou Diallo',
        role: 'Particulier',
        content: 'Enfin un service de livraison qui respecte ses engagements. Le suivi en temps réel est parfait.',
        rating: 5,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        children: [
          Text(
            'Témoignages Clients',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Découvrez ce que nos clients disent de nous',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          ...testimonials.map((testimonial) => _buildTestimonialCard(testimonial, theme)),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(TestimonialData testimonial, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          // Étoiles
          Row(
            children: List.generate(5, (index) => Icon(
              index < testimonial.rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 20,
            )),
          ),
          
          const SizedBox(height: 16),
          
          // Contenu
          Text(
            '"${testimonial.content}"',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Auteur
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: theme.primaryColor,
                radius: 20,
                child: Text(
                  testimonial.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testimonial.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    testimonial.role,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        children: [
          Text(
            'Nos Performances',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 40),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard('500+', 'Livraisons', 'par jour', Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('98%', 'Satisfaction', 'clients', Colors.green),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard('25min', 'Temps Moyen', 'de livraison', Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('24/7', 'Disponibilité', 'du service', Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            color: Colors.white,
            size: 48,
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Prêt à Commencer ?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Rejoignez des milliers de clients satisfaits au Gabon et découvrez la livraison du futur',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainWrapper()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Commencer Maintenant',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_shipping_rounded,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Smart Delivery Gabon',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Votre partenaire de livraison express au Gabon',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          Text(
            '© 2024 Smart Delivery Gabon. Tous droits réservés.',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ServiceData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<String> features;

  ServiceData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.features,
  });
}

class TestimonialData {
  final String name;
  final String role;
  final String content;
  final int rating;

  TestimonialData({
    required this.name,
    required this.role,
    required this.content,
    required this.rating,
  });
}
