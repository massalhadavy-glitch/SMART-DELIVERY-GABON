// Fichier : lib/screens/send_package_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/package.dart';
import '../providers/package_notifier.dart';
import '../providers/auth_notifier.dart';
import '../services/send_order_notification.dart';
import 'main_wrapper.dart';

class SendPackagePage extends StatefulWidget {
  final VoidCallback onSubmit;

  const SendPackagePage({super.key, required this.onSubmit});

  @override
  State<SendPackagePage> createState() => _SendPackagePageState();
}

class _SendPackagePageState extends State<SendPackagePage> {
  // Couleurs du web
  static const Color _webBackgroundStart = Color(0xFFF8F9FA);
  static const Color _webBackgroundEnd = Color(0xFFE9ECEF);
  static const Color _webTextPrimary = Color(0xFF333333);
  static const Color _webTextSecondary = Color(0xFF666666);
  static const Color _webBorderColor = Color(0xFFE9ECEF);
  static const Color _webPrimaryGreen = Color(0xFF009739);
  static const Color _webPrimaryBlue = Color(0xFF3A75C4);
  static const Color _webCardShadow = Color(0x1A000000);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController senderNameController = TextEditingController();
  final TextEditingController senderPhoneController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController recipientPhoneController = TextEditingController();
  final TextEditingController pickupAddressController = TextEditingController();
  final TextEditingController destinationAddressController = TextEditingController();
  final TextEditingController packageNatureController = TextEditingController();

  String? deliveryType;
  String? paymentMethod; // 👈 Nouveau champ
  double cost = 0.0;
  bool _isSubmitting = false;
  final Map<String, double> deliveryCosts = {
    'Livraison standard (2H à 6h)': 2000,
    'Livraison express (30min à 2h)': 3000,
    'Livraison LBV-Owendo': 3000,
    'Livraison LBV-Akanda': 3000,
    'Livraison AKANDA-Owendo': 3500,
  };
  final List<String> deliveryTypes = [
    'Livraison standard (2H à 6h)',
    'Livraison express (30min à 2h)',
    'Livraison LBV-Owendo',
    'Livraison LBV-Akanda',
    'Livraison AKANDA-Owendo',
  ];
  final List<String> paymentMethods = ['Airtel Money', 'Paiement à la livraison'];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Charger les informations de l'utilisateur connecté
  Future<void> _loadUserInfo() async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    
    if (!authNotifier.isAuthenticated) {
      return; // Pas d'utilisateur connecté
    }

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        // Si pas d'utilisateur Supabase, utiliser les infos de AuthNotifier
        final userIdentifier = authNotifier.user;
        if (userIdentifier != null && !userIdentifier.contains('@')) {
          // C'est un numéro de téléphone (format +241XXXXXXXX)
          String phone = userIdentifier.replaceAll('+', '');
          if (phone.startsWith('241') && phone.length == 11) {
            phone = '0${phone.substring(3)}'; // Convertir 241XXXXXXXX en 0XXXXXXXX
          }
          if (mounted) {
            setState(() {
              senderPhoneController.text = phone;
            });
          }
        }
        return;
      }

      // Récupérer les informations depuis la table users
      final userData = await supabase
          .from('users')
          .select('full_name, phone, email')
          .eq('id', currentUser.id)
          .maybeSingle();

      if (userData != null && mounted) {
        setState(() {
          // Pré-remplir le nom si disponible
          if (userData['full_name'] != null && userData['full_name'].toString().isNotEmpty) {
            senderNameController.text = userData['full_name'].toString();
          }
          
          // Pré-remplir le téléphone si disponible
          if (userData['phone'] != null && userData['phone'].toString().isNotEmpty) {
            String phone = userData['phone'].toString();
            // Normaliser le format
            phone = phone.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '');
            if (phone.startsWith('241') && phone.length == 11) {
              phone = '0${phone.substring(3)}'; // Convertir 241XXXXXXXX en 0XXXXXXXX
            } else if (phone.length == 8 && !phone.startsWith('0')) {
              phone = '0$phone'; // Ajouter 0 si 8 chiffres
            }
            senderPhoneController.text = phone;
          } else if (userData['email'] != null && !userData['email'].toString().contains('@')) {
            // Si l'email est en fait un téléphone
            String phone = userData['email'].toString();
            phone = phone.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '');
            if (phone.startsWith('241') && phone.length == 11) {
              phone = '0${phone.substring(3)}';
            } else if (phone.length == 8 && !phone.startsWith('0')) {
              phone = '0$phone';
            }
            senderPhoneController.text = phone;
          }
        });
      } else {
        // Si pas de données dans users, utiliser authNotifier
        final userIdentifier = authNotifier.user;
        if (userIdentifier != null && !userIdentifier.contains('@')) {
          // C'est un numéro de téléphone (format +241XXXXXXXX)
          String phone = userIdentifier.replaceAll('+', '');
          if (phone.startsWith('241') && phone.length == 11) {
            phone = '0${phone.substring(3)}'; // Convertir 241XXXXXXXX en 0XXXXXXXX
          }
          if (mounted) {
            setState(() {
              senderPhoneController.text = phone;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur lors du chargement des informations utilisateur: $e');
      // En cas d'erreur, utiliser les infos de AuthNotifier
      final userIdentifier = authNotifier.user;
      if (userIdentifier != null && !userIdentifier.contains('@')) {
        String phone = userIdentifier.replaceAll('+', '');
        if (phone.startsWith('241') && phone.length == 11) {
          phone = '0${phone.substring(3)}';
        }
        if (mounted) {
          setState(() {
            senderPhoneController.text = phone;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    senderNameController.dispose();
    senderPhoneController.dispose();
    recipientNameController.dispose();
    recipientPhoneController.dispose();
    pickupAddressController.dispose();
    destinationAddressController.dispose();
    packageNatureController.dispose();
    super.dispose();
  }

  void _updateCost(String? selectedDelivery) {
    setState(() {
      deliveryType = selectedDelivery;
      cost = selectedDelivery != null ? deliveryCosts[selectedDelivery]! : 0.0;
    });
  }

  // 👇 Simulation d’un paiement Airtel Money
  Future<bool> _processAirtelPayment(double amount) async {
    try {
      // TODO: intégrer ici la vraie API Airtel Money
      await Future.delayed(const Duration(seconds: 2)); // Simule la connexion réseau
      print('✅ Paiement Airtel Money simulé avec succès pour $amount FCFA');
      return true; // Paiement réussi
    } catch (e) {
      print('❌ Erreur Airtel Money: $e');
      return false;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        deliveryType != null &&
        paymentMethod != null) {
      
      setState(() {
        _isSubmitting = true;
      });

      // 🔹 Vérifier si Airtel Money est sélectionné
      if (paymentMethod == 'Airtel Money') {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le service Airtel Money n\'est pas encore disponible'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return; // Arrêter l'exécution ici
      }

      final trackingNumber = 'SD-${DateTime.now().millisecondsSinceEpoch % 100000}';

      final package = Package(
        id: trackingNumber,
        trackingNumber: trackingNumber,
        senderName: senderNameController.text,
        senderPhone: senderPhoneController.text,
        recipientName: recipientNameController.text,
        recipientPhone: recipientPhoneController.text,
        pickupAddress: pickupAddressController.text,
        destinationAddress: destinationAddressController.text,
        packageType: packageNatureController.text,
        deliveryType: deliveryType!,
        status: 'En attente de collecte',
        cost: cost,
        date: DateTime.now(),
        clientPhoneNumber: senderPhoneController.text,
      );

      final packageNotifier = Provider.of<PackageNotifier>(context, listen: false);

      try {

        // 🔹 Enregistrement du colis dans Firestore
        await packageNotifier.addPackage(package);

        // 🔹 Envoyer la notification WhatsApp à l'administrateur
        await SendOrderNotificationService.sendNotificationToAdmin(
          trackingNumber: trackingNumber,
          pickupAddress: pickupAddressController.text.trim(),
          destinationAddress: destinationAddressController.text.trim(),
          packageType: packageNatureController.text.trim(),
          deliveryType: deliveryType!,
          totalCost: cost,
          customerPhone: senderPhoneController.text.trim(),
          customerName: senderNameController.text.trim(),
          recipientName: recipientNameController.text.trim(),
          recipientPhone: recipientPhoneController.text.trim(),
          paymentMethod: paymentMethod ?? '',
        );

        // 🔹 Nettoyage du formulaire
        _formKey.currentState!.reset();
        setState(() {
          deliveryType = null;
          paymentMethod = null;
          cost = 0.0;
        });
        packageNatureController.clear();

        // 🔹 Message de confirmation avec redirection vers la home page
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '✅',
                    style: TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Commande validée !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _webPrimaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Votre commande a été enregistrée avec succès !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: _webTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2196F3), width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Votre numéro de suivi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _webTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          package.trackingNumber,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ Veuillez relever votre numéro de suivi pour suivre votre colis.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainWrapper(initialIndex: 0),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _webPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Retour à l\'accueil',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la soumission : $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez remplir tous les champs.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _webPrimaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
        const Divider(
          height: 1,
          thickness: 1,
          color: _webBorderColor,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(
          color: _webTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: _webTextSecondary,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _webBorderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _webBorderColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _webPrimaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: _webTextPrimary,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: _webTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _webBorderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _webBorderColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _webPrimaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: _webTextPrimary,
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.visible,
        ),
      )).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Envoyer un Colis',
          style: TextStyle(
            color: _webTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _webCardShadow,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const Text(
                      'Envoyer un Colis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _webTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Remplissez le formulaire ci-dessous pour envoyer un colis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _webTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Section Expéditeur
                    _buildFormSection(
                      'Informations Expéditeur',
                      [
                        _buildFormField(
                          controller: senderNameController,
                          label: "Nom de l'expéditeur *",
                          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: senderPhoneController,
                          label: "Téléphone de l'expéditeur *",
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                        ),
                      ],
                    ),

                    // Section Destinataire
                    _buildFormSection(
                      'Informations Destinataire',
                      [
                        _buildFormField(
                          controller: recipientNameController,
                          label: "Nom du destinataire *",
                          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: recipientPhoneController,
                          label: "Téléphone du destinataire *",
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                        ),
                      ],
                    ),

                    // Section Adresses
                    _buildFormSection(
                      'Adresses',
                      [
                        _buildFormField(
                          controller: pickupAddressController,
                          label: "Adresse de départ *",
                          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: destinationAddressController,
                          label: "Adresse de destination *",
                          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                        ),
                      ],
                    ),

                    // Section Détails du Colis
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Détails du Colis',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _webPrimaryGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: packageNatureController,
                          label: "Nature du colis *",
                          hintText: "Ex: Documents, Vêtements, etc.",
                          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          value: deliveryType,
                          label: "Type de livraison *",
                          items: deliveryTypes,
                          onChanged: _updateCost,
                          validator: (v) => v == null ? 'Veuillez sélectionner un type de livraison' : null,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                    // Mode de paiement
                    _buildDropdownField(
                      value: paymentMethod,
                      label: "Mode de paiement *",
                      items: paymentMethods,
                      onChanged: (val) {
                        setState(() => paymentMethod = val);
                        if (val == 'Airtel Money') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Le service Airtel Money n\'est pas encore disponible'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      validator: (v) => v == null ? 'Sélectionnez un mode de paiement' : null,
                    ),
                    const SizedBox(height: 24),

                    // Cost Display avec gradient
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_webPrimaryGreen, _webPrimaryBlue],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Coût: ${NumberFormat('#,###').format(cost.toInt())} FCFA',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bouton Submit
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _webPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        disabledBackgroundColor: _webPrimaryGreen.withOpacity(0.6),
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Envoi en cours...',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Soumettre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

