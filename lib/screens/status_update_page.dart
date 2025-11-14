// Fichier : lib/screens/status_update_page.dart (CORRIGÉ)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/package_notifier.dart';
import '../models/package.dart';

class StatusUpdatePage extends StatefulWidget {
  const StatusUpdatePage({super.key});

  @override
  State<StatusUpdatePage> createState() => _StatusUpdatePageState();
}

class _StatusUpdatePageState extends State<StatusUpdatePage> {
  final TextEditingController _trackingController = TextEditingController();
  String? _selectedStatus;
  Package? _foundPackage;
  String? _message;

  // ... (availableStatuses inchangé)
  final List<String> availableStatuses = Package.availableStatuses;


  void _searchPackage() {
    final trackingNumber = _trackingController.text.trim();
    final packageNotifier = Provider.of<PackageNotifier>(context, listen: false);

    // 1. Réinitialisation (dans un seul setState)
    setState(() {
      _foundPackage = null;
      _message = null;
      _selectedStatus = null; 
    });

    if (trackingNumber.isEmpty) {
      setState(() {
        _message = 'Veuillez entrer un numéro de suivi.';
      });
      return;
    }

    // 2. Logique de Recherche SÛRE via une boucle for
    final String upperTrackingNumber = trackingNumber.toUpperCase();
    Package? foundPackageResult;

    for (var package in packageNotifier.packages) {
      if (package.trackingNumber.toUpperCase() == upperTrackingNumber) {
        foundPackageResult = package;
        break; 
      }
    }

    // 3. Mise à jour de l'état
    setState(() {
      _foundPackage = foundPackageResult;
      
      if (_foundPackage != null) {
        _selectedStatus = _foundPackage!.status; 
        _message = 'Colis trouvé : ${_foundPackage!.trackingNumber}. Statut actuel : ${_foundPackage!.status}';
      } else {
        _message = 'Colis non trouvé. Vérifiez le numéro.';
      }
    });
  }

  Future<void> _updateStatus() async { // Rendre asynchrone
    if (_foundPackage == null || _selectedStatus == null) {
      setState(() {
        _message = 'Veuillez d\'abord trouver le colis et sélectionner un statut.';
      });
      return;
    }

    // Afficher un message d'attente
    setState(() {
      _message = 'Mise à jour en cours...';
    });

    try {
      final packageNotifier = Provider.of<PackageNotifier>(context, listen: false);

      // Utilise le tracking number pour Supabase
      await packageNotifier.updatePackageStatus(
        _foundPackage!.trackingNumber, 
        _selectedStatus!,
      );

      // Réinitialisation après succès
      const successMessageBase = 'Statut du colis mis à jour avec succès !';
      
      if (mounted) {
         setState(() {
          _message = successMessageBase;
          _foundPackage = null; // Réinitialiser pour masquer le formulaire
          _trackingController.clear();
          _selectedStatus = null;
        });

        // Afficher une confirmation visuelle
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(successMessageBase),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
       if (mounted) {
         setState(() {
            _message = 'Échec de la mise à jour: ${e.toString()}';
         });
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Le widget build reste le même...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outil Admin (Mise à jour Statut)'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Champ de Recherche ---
            Text('Rechercher un Colis', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _trackingController,
                    decoration: const InputDecoration(
                      labelText: 'N° de Suivi (ex: SD...)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _searchPackage(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _searchPackage,
                  icon: const Icon(Icons.search),
                  label: const Text('Rechercher'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // --- Message d'État ---
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains('succès') ? Colors.green : (_message!.contains('Erreur') || _message!.contains('Échec') ? Colors.redAccent : Colors.blue), 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

            // --- Informations et Mise à Jour ---
            if (_foundPackage != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Colis Trouvé: ${_foundPackage!.trackingNumber}', 
                          style: Theme.of(context).textTheme.headlineSmall),
                      const Divider(),
                      // Utilisation de la couleur du thème pour une meilleure visibilité dans différents thèmes
                      Text('Statut Actuel: ${_foundPackage!.status}', 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      Text('Destination: ${_foundPackage!.destinationAddress}', 
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      const SizedBox(height: 20),
                      // Dropdown de Statut
                      Text('Nouveau Statut', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      
                      DropdownButtonFormField<String>(
                        // Supprimer dropdownColor si l'on veut respecter le thème sombre/clair général
                        // decoration et styles mis à jour pour être plus robustes
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                        
                        value: _selectedStatus,
                        hint: const Text('Sélectionner le nouveau statut'),
                        
                        items: availableStatuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            // Utilisation de Theme.of(context).textTheme.bodyText1?.color pour assurer la lisibilité du texte
                            child: Text(
                              status,
                              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color), 
                            ),
                          );
                        }).toList(),
                        
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Bouton de Mise à Jour
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _updateStatus,
                          icon: const Icon(Icons.send),
                          label: const Text('Mettre à Jour le Statut'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white, // Texte blanc sur bouton orange
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}