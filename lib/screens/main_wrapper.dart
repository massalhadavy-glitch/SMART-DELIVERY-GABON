import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_notifier.dart';

// Pages utilisateur
import 'home_page.dart';
import 'orders_page.dart';
import 'send_package_page.dart';
import 'profile_page.dart';

// Pages admin
import 'admin_dashboard.dart';
import 'admin_packages_page.dart';
import 'admin_settings_page.dart';

// Page d'accueil
import 'landing_page.dart';

class MainWrapper extends StatefulWidget {
  final int? initialIndex; // Permet de spécifier l'onglet initial
  
  const MainWrapper({super.key, this.initialIndex});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Utiliser l'index initial si fourni
    if (widget.initialIndex != null) {
      _selectedIndex = widget.initialIndex!;
    }
  }

  void _onItemTapped(int index) async {
    // Si l'utilisateur appuie sur "Mes Colis" (index 1 côté utilisateur)
    // et qu'il n'est pas admin ni déjà authentifié, demander son numéro
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final isAdmin = authNotifier.isAdmin;
    final isAuthenticated = authNotifier.isAuthenticated;

    if (!isAdmin && index == 1 && !isAuthenticated) {
      String tempPhone = '';
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Voir mes colis'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Entrez votre numéro de téléphone pour afficher vos colis.'),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: 'Ex: 06xxxxxxx ou 074xxxxxx',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => tempPhone = v.trim(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );

      if (confirmed == true && tempPhone.isNotEmpty) {
        try {
          await authNotifier.loginWithPhone(tempPhone);
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Numéro invalide: $e'), backgroundColor: Colors.red),
          );
          return; // Ne pas changer d'onglet si échec
        }
      } else {
        return; // Annulé, ne pas changer d'onglet
      }
    }

    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser context.watch pour une gestion plus sûre du Provider
    final authNotifier = context.watch<AuthNotifier>();
    final isAdmin = authNotifier.isAdmin;

    // Pages utilisateur
    final List<Widget> userPages = [
      const HomePage(),
      const OrdersPage(),
      SendPackagePage(
        onSubmit: () {
          setState(() => _selectedIndex = 1); // Aller à OrdersPage après envoi
        },
      ),
      const ProfilePage(),
    ];

    // Pages admin (nouvelles pages modernes)
    final List<Widget> adminPages = [
      const AdminDashboard(),
      const AdminPackagesPage(),
      const AdminSettingsPage(),
    ];

    final currentPages = isAdmin ? adminPages : userPages;

    // Items du BottomNavigationBar
    final navItems = isAdmin
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Tableau de bord',
              tooltip: 'Tableau de bord admin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_rounded),
              label: 'Colis',
              tooltip: 'Gestion des colis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Paramètres',
              tooltip: 'Paramètres admin',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Accueil',
              tooltip: 'Page d\'accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Mes Colis',
              tooltip: 'Mes colis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.send_rounded),
              label: 'Envoyer',
              tooltip: 'Envoyer un colis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
              tooltip: 'Mon profil',
            ),
          ];

    if (_selectedIndex >= currentPages.length) {
      _selectedIndex = 0;
    }

    // Pas de vérification d'authentification pour les visiteurs
    // Les visiteurs peuvent utiliser l'application librement
    // Seuls les admins doivent se connecter via la page de login admin
    
    return Scaffold(
      body: currentPages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: isAdmin ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey[400],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: _onItemTapped,
      ),
    );
  }
}
