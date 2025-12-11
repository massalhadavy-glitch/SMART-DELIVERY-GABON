class Driver {
  final String id;
  final String name;
  final String phone;
  final String? vehicleNumber; // Numéro de la moto
  final double latitude;
  final double longitude;
  final DateTime lastUpdate;
  final bool isActive;
  final String? currentPackageId; // ID du colis en cours de livraison

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicleNumber,
    required this.latitude,
    required this.longitude,
    required this.lastUpdate,
    this.isActive = true,
    this.currentPackageId,
  });

  // Créer depuis une Map (Supabase)
  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      vehicleNumber: map['vehicle_number'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      lastUpdate: DateTime.parse(map['last_update'] as String),
      isActive: map['is_active'] as bool? ?? true,
      currentPackageId: map['current_package_id'] as String?,
    );
  }

  // Convertir en Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicle_number': vehicleNumber,
      'latitude': latitude,
      'longitude': longitude,
      'last_update': lastUpdate.toIso8601String(),
      'is_active': isActive,
      'current_package_id': currentPackageId,
    };
  }

  // Créer une copie avec des modifications
  Driver copyWith({
    String? id,
    String? name,
    String? phone,
    String? vehicleNumber,
    double? latitude,
    double? longitude,
    DateTime? lastUpdate,
    bool? isActive,
    String? currentPackageId,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isActive: isActive ?? this.isActive,
      currentPackageId: currentPackageId ?? this.currentPackageId,
    );
  }
}


