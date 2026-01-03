import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_notifier.dart';
import 'login_page.dart';
import 'send_package_page.dart';
import 'package_list_page.dart'; // À créer si tu n'as pas encore
import 'tracking_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);
    final isAdmin = authNotifier.isAdmin;
    final userRole = isAdmin ? 'Administrateur' : 'Utilisateur';
    final screenWidth = MediaQuery.of(context).size.width;

    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          // Bouton Admin - visible pour tous les utilisateurs non-admin
          if (!isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Connexion Administrateur',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          // Bouton Déconnexion - visible uniquement pour les admins
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Déconnexion',
              onPressed: () {
                authNotifier.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF009739), // Vert du drapeau gabonais (#009739)
              Color(0xFFFCD116), // Jaune du drapeau gabonais (#FCD116)
              Color(0xFF3A75C4), // Bleu du drapeau gabonais (#3A75C4)
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 16),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Bienvenue !',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                Text(
                  isAdmin ? 'Rôle: $userRole' : 'Cher(e) client(e)',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 20),

                // Contenu selon le rôle
                if (isAdmin)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Tableau de bord Admin en cours de construction...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                else
                   Column(
                     children: [
                      _buildActionCard(
                      context,
                      icon: Icons.local_shipping,
                      label: 'Envoyer un colis',
                      color: Colors.white, // Blanc comme le bouton primaire du web
                      textColor: const Color(0xFF009739), // Vert pour le texte
                      screenWidth: screenWidth,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SendPackagePage(
                                  onSubmit: () {
                                    // Callback après soumission
                                  })),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                        _buildActionCard(
                          context,
                          icon: Icons.list_alt,
                          label: 'Suivi des colis',
                          color: Colors.white.withOpacity(0.2), // Transparent comme le bouton secondaire du web
                          borderColor: Colors.white,
                          textColor: Colors.white,
                          screenWidth: screenWidth,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TrackingPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        // Section "Nos Services" comme sur le web
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Nos Services',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildServiceCard(
                                context,
                                icon: '⚡',
                                title: 'Livraison Express',
                                description: 'Livraison rapide en 30min à 2h',
                              ),
                              const SizedBox(height: 12),
                              _buildServiceCard(
                                context,
                                icon: '📋',
                                title: 'Livraison Standard',
                                description: 'Livraison standard en 2H à 6h',
                              ),
                              const SizedBox(height: 12),
                              _buildServiceCard(
                                context,
                                icon: '🌍',
                                title: 'Livraison Inter-Communes',
                                description: 'Livraison entre Libreville, Owendo et Akanda',
                              ),
                              const SizedBox(height: 12),
                              _buildServiceCard(
                                context,
                                icon: '🔒',
                                title: 'Sécurisé',
                                description: 'Suivi en temps réel de vos colis',
                              ),
                            ],
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

  // Méthode pour créer une carte de service
  Widget _buildServiceCard(BuildContext context, {
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Méthode utilitaire pour créer une carte bouton
  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required double screenWidth,
      required VoidCallback onTap,
      Color? textColor,
      Color? borderColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12), // 12px comme le web
          border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor ?? Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                  color: textColor ?? Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}