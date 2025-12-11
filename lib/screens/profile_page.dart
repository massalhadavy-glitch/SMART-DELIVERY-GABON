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
        final bool isAuthenticated = authNotifier.isAuthenticated;
        final String roleText = isAdmin ? 'Administrateur' : (isAuthenticated ? 'Client' : 'Visiteur');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            backgroundColor: isAdmin ? Colors.orange : Theme.of(context).primaryColor,
            actions: [
              // Bouton de connexion admin visible en permanence sur le web
              if (!isAdmin)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Connexion Administrateur',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // --- Informations du Compte ---
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isAdmin 
                                ? Colors.orange.withOpacity(0.2) 
                                : Theme.of(context).primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAdmin ? Icons.security : Icons.person, 
                            color: isAdmin ? Colors.orange : Theme.of(context).primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userIdentifier ?? 'Non connecté', 
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isAdmin 
                                      ? Colors.orange.withOpacity(0.1) 
                                      : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isAdmin ? Colors.orange : Colors.blue,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Rôle: $roleText',
                                  style: TextStyle(
                                    color: isAdmin ? Colors.orange : Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
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
                const SizedBox(height: 30),

                // --- Section Changement de Profil (TOUJOURS VISIBLE) ---
                Text(
                  'Changement de Profil',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Bouton de connexion admin - TOUJOURS VISIBLE
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.admin_panel_settings, color: Colors.orange, size: 24),
                    ),
                    title: const Text(
                      'Connexion Administrateur',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Accéder au tableau de bord admin'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Bouton de connexion client (téléphone)
                if (!isAdmin)
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.phone_android, color: Colors.green, size: 24),
                      ),
                      title: const Text(
                        'Connexion Client',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Se connecter avec votre numéro de téléphone'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UserLoginPage()),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 30),

                // --- Section Utilitaires Admin ---
                if (isAdmin) ...[
                  Text(
                    'Utilitaires Admin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Outil de mise à jour de statut (Visible UNIQUEMENT par l'Admin)
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.update, color: Colors.orange, size: 24),
                      ),
                      title: const Text(
                        'Mise à jour du Statut',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Modifier le statut d\'un colis'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StatusUpdatePage()),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],

                // --- Section Actions ---
                Text(
                  'Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Déconnexion (seulement pour les utilisateurs connectés)
                if (isAuthenticated)
                  Card(
                    elevation: 2,
                    color: Colors.red.withOpacity(0.05),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.logout, color: Colors.redAccent, size: 24),
                      ),
                      title: const Text(
                        'Déconnexion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      subtitle: Text('Se déconnecter de ${isAdmin ? "l'administration" : "votre compte"}'),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Déconnexion'),
                            content: Text(
                              'Êtes-vous sûr de vouloir vous déconnecter${isAdmin ? " de l'administration" : ""} ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await authNotifier.logout();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Déconnexion réussie'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                    ),
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