// Fichier : lib/screens/profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

                const SizedBox(height: 12),

                // Demande de suppression de compte (pour tous les utilisateurs connectés)
                if (isAuthenticated)
                  Card(
                    elevation: 2,
                    color: Colors.orange.withOpacity(0.05),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.orange, size: 24),
                      ),
                      title: const Text(
                        'Demander la suppression de mon compte',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      subtitle: const Text('Supprimer votre compte et toutes vos données associées'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showDeleteAccountRequestDialog(context, authNotifier, isAdmin);
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

  void _showDeleteAccountRequestDialog(BuildContext context, AuthNotifier authNotifier, bool isAdmin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Demande de suppression de compte',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vous êtes sur le point de demander la suppression de votre compte et de toutes vos données associées.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Les données suivantes seront supprimées :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Votre profil utilisateur'),
              const Text('• Vos commandes et colis'),
              const Text('• Vos informations personnelles'),
              const Text('• Votre historique de livraisons'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cette action est irréversible. Veuillez contacter le support pour finaliser votre demande.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Ouvrir l'email ou le formulaire de contact
              await _openDeleteAccountRequest(context, authNotifier);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDeleteAccountRequest(BuildContext context, AuthNotifier authNotifier) async {
    final userIdentifier = authNotifier.user ?? 'Utilisateur non identifié';
    final subject = Uri.encodeComponent('Demande de suppression de compte - Smart Delivery Gabon');
    final body = Uri.encodeComponent(
      'Bonjour,\n\n'
      'Je souhaite demander la suppression de mon compte et de toutes mes données associées.\n\n'
      'Identifiant du compte : $userIdentifier\n'
      'Date de la demande : ${DateTime.now().toString().split('.')[0]}\n\n'
      'Je confirme que je souhaite supprimer définitivement :\n'
      '- Mon profil utilisateur\n'
      '- Mes commandes et colis\n'
      '- Mes informations personnelles\n'
      '- Mon historique de livraisons\n\n'
      'Cordialement.'
    );

    // Essayer d'ouvrir l'application email
    final emailUri = Uri.parse('mailto:massalhadavy@gmail.com?subject=$subject&body=$body');
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Votre application email va s\'ouvrir. Veuillez envoyer le message pour finaliser votre demande.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        // Si l'email n'est pas disponible, afficher les informations de contact
        if (context.mounted) {
          _showContactInfoDialog(context, userIdentifier);
        }
      }
    } catch (e) {
      // Afficher les informations de contact en cas d'erreur
      if (context.mounted) {
        _showContactInfoDialog(context, userIdentifier);
      }
    }
  }

  void _showContactInfoDialog(BuildContext context, String userIdentifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email, color: Colors.blue),
            SizedBox(width: 8),
            Text('Contactez-nous'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pour demander la suppression de votre compte, veuillez nous contacter :',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Email :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SelectableText(
                'massalhadavy@gmail.com',
                style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
              const SizedBox(height: 12),
              const Text(
                'Veuillez inclure dans votre message :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• Votre identifiant : $userIdentifier'),
              const Text('• La mention "Demande de suppression de compte"'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nous traiterons votre demande dans les plus brefs délais.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}