import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/driver.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<Position>? _positionStream;

  /// Récupère tous les livreurs actifs
  Stream<List<Driver>> getActiveDrivers() {
    try {
      return _supabase
          .from('drivers')
          .stream(primaryKey: ['id'])
          .eq('is_active', true)
          .order('last_update', ascending: false)
          .map((data) {
            return data
                .map((row) => Driver.fromMap(row as Map<String, dynamic>))
                .toList();
          });
    } catch (e) {
      print('❌ Erreur getActiveDrivers: $e');
      return Stream.value([]);
    }
  }

  /// Récupère un livreur par ID
  Future<Driver?> getDriverById(String driverId) async {
    try {
      final response = await _supabase
          .from('drivers')
          .select()
          .eq('id', driverId)
          .maybeSingle();

      if (response == null) return null;
      return Driver.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('❌ Erreur getDriverById: $e');
      return null;
    }
  }

  /// Met à jour la position d'un livreur
  Future<void> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    String? packageId,
  }) async {
    try {
      await _supabase
          .from('drivers')
          .update({
            'latitude': latitude,
            'longitude': longitude,
            'last_update': DateTime.now().toIso8601String(),
            if (packageId != null) 'current_package_id': packageId,
          })
          .eq('id', driverId);

      print('✅ Position mise à jour pour le livreur $driverId');
    } catch (e) {
      print('❌ Erreur updateDriverLocation: $e');
      rethrow;
    }
  }

  /// Crée ou met à jour un livreur
  Future<Driver> upsertDriver(Driver driver) async {
    try {
      final data = driver.toMap();
      data.remove('id'); // Retirer l'id pour l'upsert

      final response = await _supabase
          .from('drivers')
          .upsert(
            {
              ...data,
              'id': driver.id,
            },
            onConflict: 'id',
          )
          .select()
          .single();

      return Driver.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('❌ Erreur upsertDriver: $e');
      rethrow;
    }
  }

  /// Démarre le suivi de position en temps réel pour un livreur
  Future<void> startLocationTracking(String driverId) async {
    // Demander les permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de localisation sont désactivés.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission de localisation refusée définitivement.');
    }

    // Démarrer le suivi
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Mettre à jour toutes les 10 mètres
      ),
    ).listen(
      (Position position) {
        updateDriverLocation(
          driverId: driverId,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      },
      onError: (error) {
        print('❌ Erreur de localisation: $error');
      },
    );

    print('✅ Suivi de localisation démarré pour le livreur $driverId');
  }

  /// Arrête le suivi de position
  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    print('🛑 Suivi de localisation arrêté');
  }

  /// Récupère la position actuelle une fois
  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('❌ Erreur getCurrentPosition: $e');
      return null;
    }
  }

  /// Calcule la distance entre deux points (en mètres)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}


