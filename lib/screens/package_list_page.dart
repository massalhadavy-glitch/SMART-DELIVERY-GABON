import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/package_notifier.dart';
import '../models/package.dart';

class PackageListPage extends StatelessWidget {
  const PackageListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final packageNotifier = Provider.of<PackageNotifier>(context);
    final List<Package> packages = packageNotifier.packages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des colis'),
      ),
      body: packages.isEmpty
          ? const Center(
              child: Text(
                'Aucun colis disponible',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final pkg = packages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    title: Text(
                      pkg.recipientName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Tracking: ${pkg.trackingNumber}'),
                        const SizedBox(height: 2),
                        Text('Statut: ${pkg.status}'),
                      ],
                    ),
                    trailing: Icon(
                      pkg.isDelivered
                          ? Icons.check_circle
                          : Icons.local_shipping,
                      color: pkg.isDelivered ? Colors.green : Colors.orange,
                    ),
                    onTap: () {
                      // Pour plus tard : afficher le détail du colis
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Détails du colis ${pkg.trackingNumber} à venir')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}