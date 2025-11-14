// Fichier : lib/screens/tracking_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/package.dart';
import '../providers/package_notifier.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final TextEditingController _trackingController = TextEditingController();
  Package? _trackedPackage;
  bool _isSearching = false;
  PackageNotifier? _packageNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = Provider.of<PackageNotifier>(context);
    if (!identical(_packageNotifier, notifier)) {
      _packageNotifier?.removeListener(_onPackagesUpdated);
      _packageNotifier = notifier;
      _packageNotifier?.addListener(_onPackagesUpdated);
    }
  }

  void _onPackagesUpdated() {
    if (!mounted || _trackedPackage == null || _packageNotifier == null) return;
    final updatedPackage = _packageNotifier!
        .getPackageByTrackingNumber(_trackedPackage!.trackingNumber);
    if (updatedPackage != null &&
        updatedPackage.status != _trackedPackage!.status) {
      setState(() {
        _trackedPackage = updatedPackage;
      });
    }
  }

  void _searchPackage() async {
    final trackingNumber = _trackingController.text.trim().toUpperCase();
    if (trackingNumber.isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
      _trackedPackage = null; // Réinitialiser le résultat précédent
    });

    if (!mounted) return;

    // Utiliser le PackageNotifier pour trouver le colis dans la liste locale
    final packageNotifier = Provider.of<PackageNotifier>(context, listen: false);
    Package? foundPackage = packageNotifier.getPackageByTrackingNumber(trackingNumber);
    
    // Si pas trouvé localement, essayer de rechercher directement dans Supabase
    if (foundPackage == null) {
      print('🔍 Colis $trackingNumber non trouvé localement, recherche dans Supabase...');
      foundPackage = await packageNotifier.getPackageByTrackingNumberFromSupabase(trackingNumber);
      if (foundPackage != null) {
        print('✅ Colis $trackingNumber trouvé dans Supabase');
      }
    }

    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _trackedPackage = foundPackage;
    });

    if (foundPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Colis $trackingNumber non trouvé.')),
      );
    }
  }

  @override
  void dispose() {
    _packageNotifier?.removeListener(_onPackagesUpdated);
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de Colis', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Entrez le Numéro de Suivi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),

            // Champ de Saisie et Bouton de Recherche
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _trackingController,
                    decoration: const InputDecoration(
                      hintText: 'Ex: SD2025-987',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => _searchPackage(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchPackage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.search, size: 24),
                              SizedBox(width: 8),
                              Text('Rechercher'),
                            ],
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- Zone d'Affichage des Résultats ---
            if (_isSearching)
              const Center(child: Text('Recherche en cours...')),

            if (_trackedPackage != null)
              _TrackingResultCard(package: _trackedPackage!),
            
            if (!_isSearching && _trackedPackage == null && _trackingController.text.isNotEmpty)
              const Center(child: Text('Aucun résultat trouvé. Veuillez vérifier le numéro de suivi.')),
          ],
        ),
      ),
    );
  }
}


// --- Widget de Résultat (Card) ---
class _TrackingResultCard extends StatelessWidget {
  final Package package;
  
  const _TrackingResultCard({required this.package});

  // Définir les étapes de la livraison
  static final List<String> deliverySteps = Package.availableStatuses;

  // Déterminer l'index de l'étape actuelle pour la Timeline
  int get currentStepIndex {
    final status = package.status;
    final index = deliverySteps.indexOf(status);
    if (index != -1) return index;

    // Gestion de secours : si le statut contient "Livré", pointer sur la dernière étape
    if (status.toLowerCase().contains('livr')) {
      return deliverySteps.length - 1;
    }

    // Si le statut est inconnu, rester à la première étape
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Colis: ${package.trackingNumber}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // Détails rapides
            _buildDetailRow(Icons.pin_drop, 'Départ', package.pickupAddress),
            _buildDetailRow(Icons.assistant_navigation, 'Arrivée', package.destinationAddress),
            _buildDetailRow(Icons.label_outline, 'Type', package.packageType),
            _buildDetailRow(Icons.local_shipping, 'Statut Actuel', package.status),

            const SizedBox(height: 20),
            Text(
              'Progression de la Livraison',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            
            // Ligne de progression visuelle (Timeline simulée)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: List.generate(deliverySteps.length, (index) {
                  final int stepIndex = currentStepIndex;
                  final bool isCompleted = stepIndex >= 0 && index <= stepIndex;
                  final bool isCurrent = stepIndex == index;

                  return Row(
                    children: [
                      Column(
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            color: isCompleted ? Theme.of(context).primaryColor : Colors.grey[400],
                            size: 20,
                          ),
                          // Ligne verticale entre les étapes (sauf la dernière)
                          if (index < deliverySteps.length - 1)
                            Container(
                              width: 2,
                              height: 30,
                              color: isCompleted ? Theme.of(context).primaryColor : Colors.grey[300],
                            ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Text(
                        deliverySteps[index],
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted ? Colors.grey[800] : Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }
}