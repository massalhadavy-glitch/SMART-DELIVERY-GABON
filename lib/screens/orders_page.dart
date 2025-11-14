// Fichier : lib/screens/orders_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/package_notifier.dart';
import '../models/package.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  // Couleurs du web
  static const Color _webBackgroundStart = Color(0xFFF8F9FA);
  static const Color _webBackgroundEnd = Color(0xFFE9ECEF);
  static const Color _webTextPrimary = Color(0xFF333333);
  static const Color _webTextSecondary = Color(0xFF666666);
  static const Color _webBorderColor = Color(0xFFE9ECEF);
  static const Color _webCardShadow = Color(0x1A000000);

  // Fonction pour obtenir la couleur du statut (comme le web)
  Color _getStatusColor(String status) {
    if (status == 'Livré') return const Color(0xFF4CAF50); // Vert
    if (status == 'Annulé') return const Color(0xFFF44336); // Rouge
    if (status.contains('En cours')) return const Color(0xFFFF9800); // Orange
    return const Color(0xFF2196F3); // Bleu par défaut
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser context.watch pour écouter automatiquement les changements
    final packageNotifier = context.watch<PackageNotifier>();
    final packages = packageNotifier.packages;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Colis',
          style: TextStyle(
            color: _webTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _webTextPrimary),
            onPressed: () {
              packageNotifier.refreshPackages();
              packageNotifier.debugPrintState();
            },
            tooltip: 'Recharger les colis',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _webBackgroundStart,
              _webBackgroundEnd,
            ],
          ),
        ),
        child: packages.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox, size: 64, color: _webTextSecondary),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun colis à afficher.',
                      style: TextStyle(
                        fontSize: 18,
                        color: _webTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Seuls vos colis sont visibles ici.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _webTextSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final package = packages[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _webCardShadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header avec tracking number et statut
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  package.trackingNumber,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _webTextPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(package.status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  package.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 24,
                            thickness: 2,
                            color: _webBorderColor,
                          ),
                          // Détails
                          _buildDetailRow(
                            'De:',
                            package.pickupAddress,
                            Icons.location_on,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Vers:',
                            package.destinationAddress,
                            Icons.location_city,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Type:',
                            package.packageType,
                            Icons.inventory_2,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Livraison:',
                            package.deliveryType,
                            Icons.local_shipping,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Coût:',
                            '${package.cost.toInt()} FCFA',
                            Icons.attach_money,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _webTextSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: _webTextSecondary,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _webTextPrimary,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
