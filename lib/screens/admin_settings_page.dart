import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_notifier.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _selectedLanguage = 'Français';
  String _selectedTheme = 'Bleu';

  final List<String> _languages = ['Français', 'English', 'Español'];
  final List<String> _themes = ['Bleu', 'Vert', 'Rouge', 'Violet'];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context, theme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil utilisateur
                _buildUserProfile(context, theme, authNotifier),
                
                const SizedBox(height: 24),
                
                // Paramètres de notifications
                _buildNotificationsSection(context, theme),
                
                const SizedBox(height: 24),
                
                // Paramètres d'apparence
                _buildAppearanceSection(context, theme),
                
                const SizedBox(height: 24),
                
                // Paramètres de sécurité
                _buildSecuritySection(context, theme, authNotifier),
                
                const SizedBox(height: 24),
                
                // Paramètres de l'application
                _buildAppSettingsSection(context, theme),
                
                const SizedBox(height: 24),
                
                // Actions dangereuses
                _buildDangerZone(context, theme, authNotifier),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.primaryColor,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paramètres',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Administration',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.save, color: Colors.white),
          onPressed: () {
            _saveSettings();
          },
        ),
      ],
    );
  }

  Widget _buildUserProfile(BuildContext context, ThemeData theme, AuthNotifier authNotifier) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              authNotifier.user?.substring(0, 1).toUpperCase() ?? 'A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authNotifier.user ?? 'Administrateur',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Super Administrateur',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Accès complet',
                        style: TextStyle(
                          color: Colors.white,
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
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context, ThemeData theme) {
    return _buildSection(
      context,
      theme,
      'Notifications',
      Icons.notifications,
      [
        _buildSwitchTile(
          'Notifications activées',
          'Recevoir des notifications push',
          _notificationsEnabled,
          (value) => setState(() => _notificationsEnabled = value),
        ),
        _buildSwitchTile(
          'Notifications email',
          'Recevoir des notifications par email',
          _emailNotifications,
          (value) => setState(() => _emailNotifications = value),
        ),
        _buildSwitchTile(
          'Notifications push',
          'Recevoir des notifications push sur l\'appareil',
          _pushNotifications,
          (value) => setState(() => _pushNotifications = value),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context, ThemeData theme) {
    return _buildSection(
      context,
      theme,
      'Apparence',
      Icons.palette,
      [
        _buildSwitchTile(
          'Mode sombre',
          'Activer le thème sombre',
          _darkMode,
          (value) => setState(() => _darkMode = value),
        ),
        _buildDropdownTile(
          'Langue',
          'Sélectionner la langue de l\'interface',
          _selectedLanguage,
          _languages,
          (value) => setState(() => _selectedLanguage = value!),
        ),
        _buildDropdownTile(
          'Thème',
          'Couleur principale de l\'application',
          _selectedTheme,
          _themes,
          (value) => setState(() => _selectedTheme = value!),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context, ThemeData theme, AuthNotifier authNotifier) {
    return _buildSection(
      context,
      theme,
      'Sécurité',
      Icons.security,
      [
        _buildActionTile(
          'Changer l\'email',
          'Mettre à jour votre adresse email',
          Icons.email,
          () {
            _showChangeEmailDialog(authNotifier);
          },
        ),
        _buildActionTile(
          'Changer le mot de passe',
          'Mettre à jour votre mot de passe',
          Icons.lock,
          () {
            _showChangePasswordDialog(authNotifier);
          },
        ),
        _buildActionTile(
          'Authentification à deux facteurs',
          'Ajouter une couche de sécurité supplémentaire',
          Icons.verified_user,
          () {
            _showTwoFactorDialog();
          },
        ),
        _buildActionTile(
          'Sessions actives',
          'Gérer les sessions connectées',
          Icons.devices,
          () {
            _showSessionsDialog();
          },
        ),
      ],
    );
  }

  Widget _buildAppSettingsSection(BuildContext context, ThemeData theme) {
    return _buildSection(
      context,
      theme,
      'Application',
      Icons.apps,
      [
        _buildActionTile(
          'À propos',
          'Informations sur l\'application',
          Icons.info,
          () {
            _showAboutDialog();
          },
        ),
        _buildActionTile(
          'Support',
          'Contacter le support technique',
          Icons.help,
          () {
            _showSupportDialog();
          },
        ),
        _buildActionTile(
          'Mise à jour',
          'Vérifier les mises à jour disponibles',
          Icons.system_update,
          () {
            _checkForUpdates();
          },
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context, ThemeData theme, AuthNotifier authNotifier) {
    return _buildSection(
      context,
      theme,
      'Zone dangereuse',
      Icons.warning,
      [
        _buildActionTile(
          'Déconnexion',
          'Se déconnecter de l\'application',
          Icons.logout,
          () {
            _showLogoutDialog(authNotifier);
          },
          isDangerous: true,
        ),
        _buildActionTile(
          'Supprimer le compte',
          'Supprimer définitivement le compte admin',
          Icons.delete_forever,
          () {
            _showDeleteAccountDialog(authNotifier);
          },
          isDangerous: true,
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, ThemeData theme, String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, String value, List<String> options, ValueChanged<String?> onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDangerous = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDangerous ? Colors.red : Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDangerous ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres sauvegardés avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showChangeEmailDialog(AuthNotifier authNotifier) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.email, color: Colors.blue),
              SizedBox(width: 8),
              Text('Changer l\'email'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email actuel: ${authNotifier.user ?? "Non disponible"}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Nouvel email',
                    hintText: 'nouveau@example.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe actuel',
                    hintText: 'Confirmez avec votre mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isLoading,
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        actions: [
          TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                    if (emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez entrer un nouvel email'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez entrer votre mot de passe actuel'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() => isLoading = true);

                    try {
                      // Vérifier le mot de passe actuel
                      final isValid = await authNotifier.verifyCurrentPassword(
                        passwordController.text,
                      );

                      if (!isValid) {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mot de passe incorrect'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }

                      // Mettre à jour l'email
                      await authNotifier.updateEmail(emailController.text.trim());

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email mis à jour avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Changer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(AuthNotifier authNotifier) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.blue),
              SizedBox(width: 8),
              Text('Changer le mot de passe'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe actuel',
                    hintText: 'Entrez votre mot de passe actuel',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    hintText: 'Au moins 6 caractères',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le nouveau mot de passe',
                    hintText: 'Répétez le nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  enabled: !isLoading,
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                    if (currentPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez entrer votre mot de passe actuel'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Le nouveau mot de passe doit contenir au moins 6 caractères'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Les mots de passe ne correspondent pas'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() => isLoading = true);

                    try {
                      // Vérifier le mot de passe actuel
                      final isValid = await authNotifier.verifyCurrentPassword(
                        currentPasswordController.text,
                      );

                      if (!isValid) {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mot de passe actuel incorrect'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }

                      // Mettre à jour le mot de passe
                      await authNotifier.updatePassword(
                        newPasswordController.text,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mot de passe mis à jour avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Changer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTwoFactorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentification à deux facteurs'),
        content: const Text('Cette fonctionnalité sera disponible prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sessions actives'),
        content: const Text('Cette fonctionnalité sera disponible prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Delivery Gabon',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_shipping, size: 48),
      children: [
        const Text('Application de gestion de livraison pour le Gabon.'),
        const SizedBox(height: 16),
        const Text('Développé avec Flutter et Supabase.'),
      ],
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support technique'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pour toute assistance technique :'),
            SizedBox(height: 16),
            Text('📧 Email: support@smartdelivery.ga'),
            Text('📞 Téléphone: +241 77 77 36 27'),
            Text('💬 Chat: Disponible 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vérification des mises à jour...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(AuthNotifier authNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authNotifier.logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AuthNotifier authNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la suppression du compte
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suppression du compte non implémentée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
