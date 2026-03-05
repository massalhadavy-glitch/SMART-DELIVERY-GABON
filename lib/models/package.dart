class Package {
  final String id; // ID du document Supabase
  final String trackingNumber;
  final String senderName;
  final String senderPhone;
  final String recipientName;
  final String recipientPhone;
  final String pickupAddress;
  final String destinationAddress;
  final String packageType;
  final double? packageValue; // Valeur du colis en FCFA
  final String deliveryType;
  final String status;
  final double cost;
  final DateTime date;
  final String clientPhoneNumber;

  static const List<String> availableStatuses = [
    'En attente de collecte',
    'Ramassé par le transporteur',
    'En transit vers Libreville',
    'En transit vers l\'intérieur',
    'Prêt à la livraison',
    'En cours de livraison',
    'Livré',
    'Annulé',
  ];

  Package({
    required this.id,
    required this.trackingNumber,
    required this.senderName,
    required this.senderPhone,
    required this.recipientName,
    required this.recipientPhone,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.packageType,
    this.packageValue,
    required this.deliveryType,
    required this.status,
    required this.cost,
    required this.date,
    required this.clientPhoneNumber,
  });
  bool get isDelivered => status == 'Livré';
  
  /// Crée une copie du colis avec un nouveau statut
  Package copyWith({String? status}) {
    return Package(
      id: id,
      trackingNumber: trackingNumber,
      senderName: senderName,
      senderPhone: senderPhone,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      packageType: packageType,
      packageValue: packageValue,
      deliveryType: deliveryType,
      status: status ?? this.status,
      cost: cost,
      date: date,
      clientPhoneNumber: clientPhoneNumber,
    );
  }
  
  // --- Conversion Supabase → Package ---
  factory Package.fromMap(Map<String, dynamic> data, [String? id]) {
    DateTime packageDate;
    
    // Gestion flexible de la date (peut être String ou DateTime)
    if (data['date'] is String) {
      packageDate = DateTime.parse(data['date']);
    } else if (data['created_at'] is String) {
      packageDate = DateTime.parse(data['created_at']);
    } else if (data['date'] is DateTime) {
      packageDate = data['date'] as DateTime;
    } else {
      packageDate = DateTime.now();
    }
    
    return Package(
      id: id ?? data['id']?.toString() ?? '',
      trackingNumber: data['tracking_number']?.toString() ?? data['trackingNumber']?.toString() ?? 'N/A',
      senderName: data['sender_name']?.toString() ?? data['senderName']?.toString() ?? '',
      senderPhone: data['sender_phone']?.toString() ?? data['senderPhone']?.toString() ?? '',
      clientPhoneNumber: data['client_phone_number']?.toString() ?? data['clientPhoneNumber']?.toString() ?? data['senderPhone']?.toString() ?? '',
      recipientName: data['recipient_name']?.toString() ?? data['recipientName']?.toString() ?? '',
      recipientPhone: data['recipient_phone']?.toString() ?? data['recipientPhone']?.toString() ?? '',
      pickupAddress: data['pickup_address']?.toString() ?? data['pickupAddress']?.toString() ?? '',
      destinationAddress: data['destination_address']?.toString() ?? data['destinationAddress']?.toString() ?? '',
      packageType: data['package_type']?.toString() ?? data['packageType']?.toString() ?? '',
      packageValue: data['package_value'] != null ? (data['package_value'] as num).toDouble() : (data['packageValue'] != null ? (data['packageValue'] as num).toDouble() : null),
      deliveryType: data['delivery_type']?.toString() ?? data['deliveryType']?.toString() ?? '',
      status: data['status']?.toString() ?? 'En attente de collecte',
      cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
      date: packageDate,
    );
  }

  // --- Conversion Package → Map pour Supabase ---
  Map<String, dynamic> toMap() {
    return {
      'tracking_number': trackingNumber,
      'sender_name': senderName,
      'sender_phone': senderPhone,
      'client_phone_number': clientPhoneNumber,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'pickup_address': pickupAddress,
      'destination_address': destinationAddress,
      'package_type': packageType,
      'package_value': packageValue,
      'delivery_type': deliveryType,
      'status': status,
      'cost': cost,
    };
  }
}
