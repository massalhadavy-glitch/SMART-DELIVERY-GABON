import 'package:flutter/material.dart';
import 'main_wrapper.dart'; // Importation nécessaire pour la redirection

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
  final _phoneController = TextEditingController();
  final _paymentCodeController = TextEditingController();
  
  // Code de paiement fixe
  static const String paymentCode = 'SDG01';
  
  // VARIABLES POUR LA SÉLECTION DE LIVRAISON
  String _selectedDeliveryType = 'Livraison standard (2H à 6h)'; 
  double _extraCost = 2000; // Coût de base pour Standard
  final Map<String, double> _deliveryOptions = {
    'Livraison standard (2H à 6h)': 2000, // Coût total pour Standard
    'Livraison express (30min à 2h)': 3000, // Coût total pour Express
    'Livraison inter commune\n(ex: Libreville-Owendo)': 3000, // Coût total pour livraison inter commune
  };

  // Calcul du coût total
  double get _totalCost => _deliveryOptions[_selectedDeliveryType] ?? 2000;

  @override
  void initState() {
    super.initState();
    // Pré-remplir le code de paiement
    _paymentCodeController.text = paymentCode;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _paymentCodeController.dispose();
    super.dispose();
  }

  void _processAirtelMoneyPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phoneNumber = _phoneController.text.trim();
    final enteredCode = _paymentCodeController.text.trim();

    // Vérifier le code de paiement
    if (enteredCode.toUpperCase() != paymentCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code de paiement incorrect. Utilisez SDG01'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Afficher un dialogue de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Numéro Airtel Money: $phoneNumber'),
            const SizedBox(height: 8),
            Text('Code de paiement: $enteredCode'),
            const SizedBox(height: 8),
            Text('Montant: ${_totalCost.toInt()} FCFA'),
            const SizedBox(height: 16),
            const Text(
              'Vous allez recevoir une demande de paiement sur votre téléphone. Confirmez le paiement pour finaliser la commande.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    // Simuler le traitement du paiement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simuler un délai de traitement
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context); // Fermer le dialogue de chargement

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paiement de ${_totalCost.toInt()} FCFA effectué avec succès !'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // TODO: Enregistrer la commande dans la base de données
    // TODO: Envoyer une notification WhatsApp
    
    // Rediriger vers la page d'accueil après un court délai
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainWrapper()),
      (route) => false,
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
            
            // --- SECTION PAIEMENT AIRTEL MONEY ---
            Text('Paiement par Airtel Money', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            
            // Afficher le code de paiement de manière proéminente
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.2),
                    Theme.of(context).primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code, color: Theme.of(context).primaryColor, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'CODE DE PAIEMENT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        paymentCode,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Theme.of(context).primaryColor, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Procédure de paiement',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentStep('1', 'Composez *133# sur votre téléphone Airtel'),
                        const SizedBox(height: 8),
                        _buildPaymentStep('2', 'Sélectionnez "Payer une facture" ou "Payer"'),
                        const SizedBox(height: 8),
                        _buildPaymentStep('3', 'Entrez le code de paiement: $paymentCode'),
                        const SizedBox(height: 8),
                        _buildPaymentStep('4', 'Confirmez le montant: ${_totalCost.toInt()} FCFA'),
                        const SizedBox(height: 8),
                        _buildPaymentStep('5', 'Entrez votre code PIN pour valider'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // --- FORMULAIRE DE PAIEMENT ---
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Numéro Airtel Money',
                      hintText: 'Ex: 06 xxxxxxx ou 074xxxxxx',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      // Validation basique du format (6 ou 7 chiffres après le préfixe)
                      final phoneRegex = RegExp(r'^(06|07|074|075|076|077|078|079)\d{6,7}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'Numéro invalide. Format: 06xxxxxxx ou 074xxxxxx';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _paymentCodeController,
                    decoration: InputDecoration(
                      labelText: 'Code de paiement',
                      hintText: 'SDG01',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Le code de paiement est SDG01'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le code de paiement';
                      }
                      if (value.trim().toUpperCase() != paymentCode) {
                        return 'Code incorrect. Utilisez SDG01';
                      }
                      return null;
                    },
                  ),
                ],
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

  Widget _buildPaymentStep(String stepNumber, String instruction) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            instruction,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}