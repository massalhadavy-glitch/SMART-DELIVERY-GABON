import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // La couleur primaire est le Rouge/Orange du thème
    final Color primaryColor = Theme.of(context).primaryColor;

    return DefaultTabController(
      length: 2, // 2 onglets : Adresses et Produits
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mes Favoris',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          // La barre d'onglets
          bottom: TabBar(
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Adresses', icon: Icon(Icons.location_on_outlined)),
              Tab(text: 'Produits', icon: Icon(Icons.shopping_bag_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Contenu pour l'onglet "Adresses"
            _buildAddressesTab(),
            // Contenu pour l'onglet "Produits"
            _buildProductsTab(),
          ],
        ),
      ),
    );
  }

  // Widget pour l'onglet des adresses favorites
  Widget _buildAddressesTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          leading: const Icon(Icons.home, color: Colors.orangeAccent),
          title: const Text('Maison'),
          subtitle: const Text('Quartier Batterie IV, Rue des Écoles'),
          trailing: const Icon(Icons.delete_outline, color: Colors.red),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.work, color: Colors.blueAccent),
          title: const Text('Bureau'),
          subtitle: const Text('Immeuble Vert, Centre-Ville'),
          trailing: const Icon(Icons.delete_outline, color: Colors.red),
          onTap: () {},
        ),
        const Divider(),
        const Center(
          child: Text('Appuyez sur le ❤️ sur la carte pour ajouter une adresse.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }

  // Widget pour l'onglet des produits/colis favoris
  Widget _buildProductsTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Aucun article ou colis favori pour le moment.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}