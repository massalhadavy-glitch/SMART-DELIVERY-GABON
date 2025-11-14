import 'package:flutter/material.dart';
import '../models/package.dart';

class PackageDetailPage extends StatelessWidget {
  final Package package;

  const PackageDetailPage({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final bool isDelivered = package.isDelivered;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suivi: ${package.trackingNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Statut Actuel ---
            _buildStatusCard(context, package.status, isDelivered),
            const SizedBox(height: 30),

            // --- Informations Générales ---
            Text(
              'Détails de l\'Envoi',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow(Icons.location_on_outlined, 'Ramassage', package.pickupAddress),
            _buildInfoRow(Icons.pin_drop_outlined, 'Destination', package.destinationAddress),
            _buildInfoRow(Icons.inventory_2_outlined, 'Type de Colis', package.packageType),
            _buildInfoRow(Icons.schedule, 'Livraison', package.deliveryType),
            _buildInfoRow(Icons.attach_money, 'Coût', '${package.cost.toInt()} FCFA'),
            const SizedBox(height: 30),

            // --- Chronologie de Suivi ---
            Text(
              'Chronologie du Colis',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 10),

            _buildTimeline(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Widgets Utilitaires (Définis comme méthodes internes) ---

  Widget _buildStatusCard(BuildContext context, String status, bool isDelivered) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.local_shipping;

    if (isDelivered) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'Annulé') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (status == 'En attente de collecte') {
      statusColor = Colors.yellow;
      statusIcon = Icons.pending;
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: statusColor.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(statusIcon, size: 40, color: statusColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statut Actuel',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey[700])),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w400, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final timeline = _getTrackingTimeline();

    int currentStatusIndex =
        timeline.indexWhere((e) => e['status'] == package.status);
    if (currentStatusIndex == -1) {
      currentStatusIndex = 0;
    }

    return Column(
      children: timeline.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;

        final bool isCurrent = index == currentStatusIndex;
        final bool isPast = index < currentStatusIndex;

        Color dotColor =
            isCurrent ? Theme.of(context).primaryColor : (isPast ? Colors.green : Colors.grey);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Expanded(
                    child: Container(
                      width: 2,
                      color: index == 0
                          ? Colors.transparent
                          : (isPast ? Colors.green : Colors.grey),
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: dotColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['status'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? Theme.of(context).primaryColor
                              : (isPast ? Colors.green[700] : Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event['location'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        '${(event['time'] as DateTime).day}/${(event['time'] as DateTime).month} à ${(event['time'] as DateTime).hour}h${(event['time'] as DateTime).minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Données de chronologie ---
  List<Map<String, dynamic>> _getTrackingTimeline() {
    return [
      {
        'status': 'En attente de collecte',
        'location': package.pickupAddress,
        'time': package.date.subtract(const Duration(days: 3)),
      },
      {
        'status': 'En transit',
        'location': 'Centre logistique principal',
        'time': package.date.subtract(const Duration(days: 2, hours: 3)),
      },
      {
        'status': 'En cours de livraison',
        'location': 'Sur le trajet vers ${package.destinationAddress}',
        'time': package.date.subtract(const Duration(days: 1, hours: 5)),
      },
      {
        'status': 'Livré',
        'location': package.destinationAddress,
        'time': package.date.subtract(const Duration(hours: 2)),
      },
    ];
  }
}