import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_notifier.dart';
import '../services/supabase_package_service.dart';
import 'main_wrapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    try {
      // Connexion admin par email
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      print('📧 Tentative de connexion avec: $email');

      // Connexion Supabase
      final userCredential = await authNotifier.loginWithEmail(email, password);

      print('✅ Connexion réussie pour userId: ${userCredential.user!.id}');
      print('✅ Rôle détecté: ${authNotifier.role}');

      // Vérifier que l'utilisateur est bien admin
      if (!authNotifier.isAdmin) {
        print('❌ Accès refusé: l\'utilisateur n\'est pas admin (rôle: ${authNotifier.role})');
        
        // Déconnecter l'utilisateur
        await authNotifier.logout();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Accès refusé : Vous n'êtes pas autorisé comme administrateur.\n"
              "Contactez un administrateur pour obtenir les droits d'accès."
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      print('🎉 Accès admin accordé!');

      // Succès - Rediriger vers MainWrapper
      if (!mounted) return;
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bienvenue Administrateur!\n${authNotifier.user}"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Attendre un peu pour que le message s'affiche
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainWrapper()),
      );
    } catch (e) {
      print('❌ Erreur de connexion: $e');
      
      if (!mounted) return;
      
      String errorMessage = 'Erreur de connexion';
      
      // Gestion des erreurs spécifiques
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = "Email ou mot de passe incorrect.\nVérifiez vos identifiants.";
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = "Email non confirmé.\nVérifiez votre boîte mail.";
      } else if (e.toString().contains('network') || e.toString().contains('SocketException')) {
        errorMessage = "Problème de connexion réseau.\nVérifiez votre connexion internet.";
      } else if (e.toString().contains('Aucun utilisateur')) {
        errorMessage = "Utilisateur non trouvé.\nVérifiez votre email.";
      } else {
        errorMessage = 'Erreur : ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo et titre avec icône
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.3),
                        primaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 60,
                    color: primaryColor,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                Text(
                  'Connexion Admin',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Accès réservé aux administrateurs',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 50),

                // Formulaire de connexion
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Champ Email
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entrez votre email';
                            }
                            final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!regex.hasMatch(value)) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Champ Mot de passe
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Minimum 6 caractères';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton de connexion
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : () => _login(context),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Bouton retour
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Retour',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}