import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/package_notifier.dart';
import '../models/package.dart';
import 'package_detail_page.dart';
import 'status_update_page.dart';

class AdminPackagesPage extends StatefulWidget {
  const AdminPackagesPage({super.key});

  @override
  State<AdminPackagesPage> createState() => _AdminPackagesPageState();
}

class _AdminPackagesPageState extends State<AdminPackagesPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedFilter = 'Tous';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = [
    'Tous',
    'En attente',
    'En cours',
    'Livré',
    'Annulé',
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Utiliser context.watch pour écouter automatiquement les changements
    final packageNotifier = context.watch<PackageNotifier>();
    final packages = _getFilteredPackages(packageNotifier.packages);
    
    // Debug logs pour l'admin
    print('🔍 AdminPackagesPage - Nombre total de colis: ${packageNotifier.packages.length}');
    print('🔍 AdminPackagesPage - Filtre sélectionné: $_selectedFilter');
    print('🔍 AdminPackagesPage - Colis après filtrage: ${packages.length}');
    for (var package in packageNotifier.packages) {
      print('📦 Admin voit: ${package.trackingNumber} - ${package.status}');
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context, theme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Barre de recherche et filtres
              _buildSearchAndFilters(context, theme),
              
              // Statistiques rapides
              _buildQuickStats(context, theme, packageNotifier.packages),
              
              // Liste des colis
              Expanded(
                child: packages.isEmpty
                    ? _buildEmptyState(context, theme)
                    : _buildPackagesList(context, theme, packages),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StatusUpdatePage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Mettre à jour'),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.primaryColor,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des Colis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Administration',
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
          onPressed: () {
            // Rafraîchir les données
            final packageNotifier = Provider.of<PackageNotifier>(context, listen: false);
            packageNotifier.refreshPackages();
            packageNotifier.debugPrintState();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Données actualisées')),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) async {
            final packageNotifier = Provider.of<PackageNotifier>(context, listen: false);
            
            if (value == 'reset_all_cache') {
              // Demander confirmation pour réinitialiser tous les caches
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Réinitialiser tous les caches'),
                  content: const Text(
                    'Êtes-vous sûr de vouloir réinitialiser tous les caches de colis d\'utilisateurs ?\n\n'
                    'Cette action supprimera tous les colis en mémoire pour tous les utilisateurs.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && mounted) {
                // Pour réinitialiser tous les caches, on doit itérer sur tous les utilisateurs uniques
                final allUserPhones = <String>{};
                for (var package in packageNotifier.packages) {
                  if (package.clientPhoneNumber.isNotEmpty) {
                    allUserPhones.add(package.clientPhoneNumber);
                  }
                  if (package.senderPhone.isNotEmpty) {
                    allUserPhones.add(package.senderPhone);
                  }
                }
                
                for (var phone in allUserPhones) {
                  await packageNotifier.resetUserPackages(phone);
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tous les caches ont été réinitialisés'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'reset_all_cache',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Réinitialiser tous les caches'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Exporter'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  Icon(Icons.upload),
                  SizedBox(width: 8),
                  Text('Importer'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un colis...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) => _buildFilterChip(filter)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, ThemeData theme, List<Package> packages) {
    final total = packages.length;
    final delivered = packages.where((p) => p.isDelivered).length;
    final pending = packages.where((p) => !p.isDelivered).length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Total', total.toString(), Icons.local_shipping),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem('Livrés', delivered.toString(), Icons.check_circle),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem('En cours', pending.toString(), Icons.hourglass_empty),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun colis trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Aucun résultat pour "$_searchQuery"'
                  : 'Commencez par ajouter des colis',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatusUpdatePage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un colis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackagesList(BuildContext context, ThemeData theme, List<Package> packages) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return _buildPackageCard(context, theme, package);
      },
    );
  }

  Widget _buildPackageCard(BuildContext context, ThemeData theme, Package package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PackageDetailPage(package: package),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec statut
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        package.recipientName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusChip(package.status, package.isDelivered),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Informations du colis
                Row(
                  children: [
                    Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Tracking: ${package.trackingNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Destination: ${package.destinationAddress}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Informations client avec option de réinitialisation
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Client: ${package.clientPhoneNumber.isNotEmpty ? package.clientPhoneNumber : package.senderPhone}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    if (package.clientPhoneNumber.isNotEmpty || package.senderPhone.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                        tooltip: 'Réinitialiser les colis de cet utilisateur',
                        onPressed: () async {
                          final userPhone = package.clientPhoneNumber.isNotEmpty 
                              ? package.clientPhoneNumber 
                              : package.senderPhone;
                          
                          if (userPhone.isEmpty) return;
                          
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Réinitialiser les colis'),
                              content: Text(
                                'Êtes-vous sûr de vouloir réinitialiser tous les colis en mémoire pour l\'utilisateur :\n\n'
                                '$userPhone ?\n\n'
                                'Cette action supprimera tous les colis en mémoire pour cet utilisateur.'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Réinitialiser'),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirmed == true && mounted) {
                            final packageNotifier = Provider.of<PackageNotifier>(context, listen: false);
                            try {
                              await packageNotifier.resetUserPackages(userPhone);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Colis de l\'utilisateur $userPhone réinitialisés'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PackageDetailPage(package: package),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Voir détails'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(color: theme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StatusUpdatePage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Modifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDelivered) {
    Color color;
    IconData icon;
    
    if (isDelivered) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (status.toLowerCase().contains('en cours')) {
      color = Colors.orange;
      icon = Icons.local_shipping;
    } else if (status.toLowerCase().contains('attente')) {
      color = Colors.blue;
      icon = Icons.hourglass_empty;
    } else {
      color = Colors.red;
      icon = Icons.cancel;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Package> _getFilteredPackages(List<Package> packages) {
    List<Package> filtered = packages;
    
    // Filtrage par statut
    if (_selectedFilter != 'Tous') {
      filtered = filtered.where((package) {
        switch (_selectedFilter) {
          case 'En attente':
            return package.status.toLowerCase().contains('attente');
          case 'En cours':
            return package.status.toLowerCase().contains('cours') || 
                   package.status.toLowerCase().contains('transit');
          case 'Livré':
            return package.isDelivered;
          case 'Annulé':
            return package.status.toLowerCase().contains('annulé') ||
                   package.status.toLowerCase().contains('cancel');
          default:
            return true;
        }
      }).toList();
    }
    
    // Filtrage par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((package) {
        return package.recipientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               package.trackingNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               package.destinationAddress.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }
}
