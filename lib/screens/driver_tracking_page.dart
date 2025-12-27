import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/driver_location_service.dart';
import '../models/driver.dart';
import '../providers/auth_notifier.dart';

class DriverTrackingPage extends StatefulWidget {
  const DriverTrackingPage({super.key});

  @override
  State<DriverTrackingPage> createState() => _DriverTrackingPageState();
}

class _DriverTrackingPageState extends State<DriverTrackingPage> {
  final DriverLocationService _locationService = DriverLocationService();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<Driver> _drivers = [];
  Driver? _selectedDriver;
  bool _isLoading = true;

  // Position par défaut (Libreville, Gabon)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(0.3921, 9.4536),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  void _loadDrivers() {
    setState(() => _isLoading = true);

    _locationService.getActiveDrivers().listen(
      (drivers) {
        if (mounted) {
          setState(() {
            _drivers = drivers;
            _isLoading = false;
            _updateMarkers();
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _updateMarkers() {
    _markers.clear();

    for (var driver in _drivers) {
      final marker = Marker(
        markerId: MarkerId(driver.id),
        position: LatLng(driver.latitude, driver.longitude),
        infoWindow: InfoWindow(
          title: driver.name,
          snippet: driver.vehicleNumber ?? driver.phone,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          driver.isActive
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        onTap: () {
          setState(() {
            _selectedDriver = driver;
          });
          _showDriverInfo(driver);
        },
      );
      _markers.add(marker);
    }

    // Centrer la carte sur tous les livreurs si plusieurs
    if (_drivers.isNotEmpty && _mapController != null) {
      _fitBounds();
    }
  }

  void _fitBounds() {
    if (_drivers.isEmpty) return;

    double minLat = _drivers.first.latitude;
    double maxLat = _drivers.first.latitude;
    double minLng = _drivers.first.longitude;
    double maxLng = _drivers.first.longitude;

    for (var driver in _drivers) {
      minLat = minLat < driver.latitude ? minLat : driver.latitude;
      maxLat = maxLat > driver.latitude ? maxLat : driver.latitude;
      minLng = minLng < driver.longitude ? minLng : driver.longitude;
      maxLng = maxLng > driver.longitude ? maxLng : driver.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.01, minLng - 0.01),
          northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        100,
      ),
    );
  }

  void _showDriverInfo(Driver driver) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        driver.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (driver.vehicleNumber != null) ...[
              _buildInfoRow(Icons.motorcycle, 'Moto', driver.vehicleNumber!),
              const SizedBox(height: 8),
            ],
            _buildInfoRow(
              Icons.access_time,
              'Dernière mise à jour',
              _formatTime(driver.lastUpdate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.location_on,
              'Position',
              '${driver.latitude.toStringAsFixed(6)}, ${driver.longitude.toStringAsFixed(6)}',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _centerOnDriver(driver);
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('Centrer sur la carte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Ouvrir les détails du colis si currentPackageId existe
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('Voir colis'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }

  void _centerOnDriver(Driver driver) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(driver.latitude, driver.longitude),
        15,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: const Row(
          children: [
            Icon(Icons.motorcycle, color: Colors.white),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suivi des Motos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Localisation en temps réel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDrivers,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte Google Maps
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_drivers.isNotEmpty) {
                _fitBounds();
              }
            },
          ),

          // Indicateur de chargement
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Liste des livreurs (en bas)
          if (!_isLoading && _drivers.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Livreurs actifs (${_drivers.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _drivers.length,
                        itemBuilder: (context, index) {
                          final driver = _drivers[index];
                          return _buildDriverCard(driver);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Message si aucun livreur
          if (!_isLoading && _drivers.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.motorcycle_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun livreur actif',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucun livreur n\'est actuellement en service',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return GestureDetector(
      onTap: () {
        _centerOnDriver(driver);
        _showDriverInfo(driver);
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedDriver?.id == driver.id
                ? Colors.blue
                : Colors.grey[300]!,
            width: _selectedDriver?.id == driver.id ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (driver.vehicleNumber != null)
                        Text(
                          driver.vehicleNumber!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _formatTime(driver.lastUpdate),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


