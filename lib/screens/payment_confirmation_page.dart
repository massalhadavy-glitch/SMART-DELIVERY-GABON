import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/package_notifier.dart';
import '../models/package.dart';
import 'package:intl/intl.dart';
import 'main_wrapper.dart'; // Importation nécessaire pour la redirection
import '../services/send_order_notification.dart'; // Service centralisé notifications
import '../config/admin_config.dart'; // Configuration admin

class PaymentConfirmationPage extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final String packageType;
  final double deliveryCostBase; // COÛT INITIAL TRANSMIS

  const PaymentConfirmationPage({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.packageType,
    required this.deliveryCostBase, // Récupération du coût initial
  });

  @override
  State<PaymentConfirmationPage> createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  
  // VARIABLES POUR LA SÉLECTION DE LIVRAISON
  String _selectedDeliveryType = 'Standard (6H à 12H)'; 
  double _extraCost = 2000; // Coût de base pour Standard
  final Map<String, double> _deliveryOptions = {
    'Standard (6H à 12H)': 2000, // Coût total pour Standard
    'Express (2H à 5H)': 3000, // Coût total pour Express
    'Livraison inter commune\n(ex: Libreville-Owendo)': 3000, // Coût total pour livraison inter commune
  };

  // Calcul du coût total
  double get _totalCost => _deliveryOptions[_selectedDeliveryType] ?? 2000;


  void _processAirtelMoneyPayment() async {
    // Afficher le message indiquant que le service n'est pas encore disponible
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Le service Airtel Money n\'est pas encore disponible'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmer le Paiement', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NOUVELLE SECTION : CHOIX DE LIVRAISON ---
            Text('Options de Livraison', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            
            ..._deliveryOptions.entries.map((entry) {
              final type = entry.key;
              final cost = entry.value;

              return RadioListTile<String>(
                title: Text(
                  '$type (${cost.toInt()} FCFA)',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  softWrap: true,
                  maxLines: 2,
                ),
                value: type,
                groupValue: _selectedDeliveryType,
                onChanged: (String? value) {
                  setState(() {
                    _selectedDeliveryType = value!;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              );
            }).toList(),
            
            const SizedBox(height: 30),
            // --- FIN NOUVELLE SECTION ---

            // --- SECTION DÉTAILS DE LA COMMANDE ---
            Text('Détails de la Commande', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow(context, 'Ramassage', widget.pickupAddress),
            _buildDetailRow(context, 'Destination', widget.destinationAddress),
            _buildDetailRow(context, 'Type de Colis', widget.packageType),
            _buildDetailRow(context, 'Option Choisie', _selectedDeliveryType), // AFFICHAGE DYNAMIQUE
            
            const SizedBox(height: 20),
            
            // --- COÛT TOTAL ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Coût Total à Payer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(
                    '${_totalCost.toInt()} FCFA', // UTILISE LE COÛT TOTAL DYNAMIQUE
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // --- FORMULAIRE DE PAIEMENT ---
            Form(
              key: _formKey,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro Airtel Money',
                  hintText: 'Ex: 06 xxxxxxx',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
                onChanged: (value) => _phoneNumber = value,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // --- BOUTON DE PAIEMENT ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _processAirtelMoneyPayment,
                icon: const Icon(Icons.payment),
                label: Text('Payer ${_totalCost.toInt()} FCFA'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$title :', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              softWrap: true,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}