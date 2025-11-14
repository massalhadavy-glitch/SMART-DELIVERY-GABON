// Fichier : lib/screens/profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_notifier.dart';
import 'status_update_page.dart';
import 'login_page.dart';
import 'user_login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Le Consumer écoute les changements dans l'AuthNotifier
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        // Le rôle de l'utilisateur est accessible ici
        final String? userIdentifier = authNotifier.user;
        final bool isAdmin = authNotifier.isAdmin;
        final String roleText = isAdmin ? 'Administrateur' : 'Client';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            backgroundColor: isAdmin ? Colors.orange : Theme.of(context).primaryColor,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // --- Informations du Compte ---
                Card(
                  child: ListTile(
                    leading: Icon(isAdmin ? Icons.security : Icons.person, 
                                 color: isAdmin ? Colors.orange : Theme.of(context).primaryColor),
                    title: Text(userIdentifier ?? 'Utilisateur Inconnu', 
                                 style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Rôle: $roleText'),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Section Réglages et Utilitaires ---
                Text('Utilitaires', style: Theme.of(context).textTheme.titleLarge),
                const Divider(),

                // Outil de mise à jour de statut (Visible UNIQUEMENT par l'Admin)
                if (isAdmin) // <-- LA CONDITION CLÉ
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.orange),
                    title: const Text('Outil Admin (Mise à jour Statut)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        // Correction de la syntaxe const pour MaterialPageRoute
                        MaterialPageRoute(builder: (context) => const StatusUpdatePage()),
                      );
                    },
                  ),
                
                // --- Connexions (pour les visiteurs) ---
                if (!isAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.phone_android, color: Colors.green),
                    title: const Text('Connexion (Téléphone)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserLoginPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                    title: const Text('Connexion Administrateur'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                  ),
                ],
                
                // --- Déconnexion (seulement pour les admins connectés) ---
                if (isAdmin)
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Déconnexion'),
                    onTap: () {
                      authNotifier.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Déconnexion réussie'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}