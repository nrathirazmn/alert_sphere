import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/incident_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  String _selectedFilter = 'All';
  bool _showLegend = false;

  static const LatLng _initialPosition = LatLng(4.5975, 101.0901); // Ipoh, Malaysia

  final List<String> _filters = ['All', 'Flood', 'Fire', 'Landslide', 'Storm', 'Haze', 'Earthquake'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createMarkers();
    });
  }

  void _createMarkers() {
    final incidents = Provider.of<IncidentProvider>(context, listen: false).incidents;

    setState(() {
      _markers.clear();
      
      for (final incident in incidents) {
        // Filter logic
        if (_selectedFilter != 'All' && incident.type != _selectedFilter) {
          continue;
        }

        // ✅ USE REAL COORDINATES - No more hardcoding!
        if (incident.hasCoordinates) {
          _markers.add(
            Marker(
              markerId: MarkerId(incident.id),
              position: LatLng(
                incident.latitude!,  // Real latitude from API
                incident.longitude!, // Real longitude from API
              ),
              infoWindow: InfoWindow(
                title: '${incident.type} - ${incident.urgency}',
                snippet: incident.description,
                onTap: () {
                  _showIncidentDetails(incident);
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getMarkerColor(incident.type),
              ),
              onTap: () {
                _showIncidentDetails(incident);
              },
            ),
          );
        } else {
          print('⚠️ Skipping incident without coordinates: ${incident.location}');
        }
      }
      
      print('📍 Created ${_markers.length} markers with real coordinates');
      
      // Auto-fit camera to show all markers
      if (_markers.isNotEmpty && _mapController != null) {
        _fitMapToMarkers();
      }
    });
  }

  void _fitMapToMarkers() {
    if (_markers.isEmpty) return;
    
    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;
    
    for (var marker in _markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100, // padding
      ),
    );
  }

  void _showIncidentDetails(incident) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getLegendColor(incident.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIncidentIcon(incident.type),
                    color: _getLegendColor(incident.type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.type,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        incident.urgency,
                        style: TextStyle(
                          color: _getUrgencyColor(incident.urgency),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              incident.description,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    incident.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(incident.timestamp),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (incident.hasCoordinates) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.my_location, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Lat: ${incident.latitude!.toStringAsFixed(4)}, Lng: ${incident.longitude!.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  IconData _getIncidentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return Icons.waves;
      case 'fire':
        return Icons.local_fire_department;
      case 'landslide':
        return Icons.landscape;
      case 'storm':
        return Icons.storm;
      case 'haze':
        return Icons.cloud;
      case 'earthquake':
        return Icons.emergency;
      default:
        return Icons.warning;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _getMarkerColor(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return BitmapDescriptor.hueBlue;
      case 'fire':
        return BitmapDescriptor.hueRed;
      case 'landslide':
        return BitmapDescriptor.hueOrange;
      case 'storm':
        return BitmapDescriptor.hueViolet;
      case 'haze':
        return BitmapDescriptor.hueCyan;
      case 'earthquake':
        return BitmapDescriptor.hueRose;
      default:
        return BitmapDescriptor.hueYellow;
    }
  }

  Color _getLegendColor(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return const Color(0xFF2196F3);
      case 'fire':
        return const Color(0xFFF44336);
      case 'landslide':
        return const Color(0xFFFF9800);
      case 'storm':
        return const Color(0xFF9C27B0);
      case 'haze':
        return const Color(0xFF607D8B);
      case 'earthquake':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFFFFEB3B);
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _createMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final incidentProvider = Provider.of<IncidentProvider>(context);
    final totalIncidents = incidentProvider.incidents.length;
    final incidentsWithCoords = incidentProvider.incidents.where((i) => i.hasCoordinates).length;

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Google Map (NO CONTAINER)
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 6,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              _fitMapToMarkers();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            mapType: MapType.normal,
          ),

          // Top Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top Status Bar - Glassmorphism
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Card with Incident Count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFF6B35).withOpacity(0.8),
                                        const Color(0xFFE63946).withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.map,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Incident Map',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_markers.length} visible on map',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.9),
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Show incident report stats
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    icon: Icons.warning_amber_rounded,
                                    label: 'Total',
                                    value: '$totalIncidents',
                                    color: Colors.orange,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  _buildStatItem(
                                    icon: Icons.location_on,
                                    label: 'Located',
                                    value: '$incidentsWithCoords',
                                    color: Colors.blue,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  _buildStatItem(
                                    icon: Icons.filter_alt,
                                    label: 'Active',
                                    value: '${_markers.length}',
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Chips - Glassmorphism
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        final count = filter == 'All' 
                            ? incidentProvider.incidents.where((i) => i.hasCoordinates).length
                            : incidentProvider.incidents.where((i) => i.type == filter && i.hasCoordinates).length;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _onFilterChanged(filter),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          filter == 'All'
                                              ? const Color(0xFFFF6B35)
                                              : _getLegendColor(filter),
                                          filter == 'All'
                                              ? const Color(0xFFE63946)
                                              : _getLegendColor(filter).withOpacity(0.8),
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: (filter == 'All'
                                                  ? const Color(0xFFFF6B35)
                                                  : _getLegendColor(filter))
                                              .withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (filter != 'All') ...[
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white
                                                : _getLegendColor(filter),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        filter,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          shadows: isSelected
                                              ? const [
                                                  Shadow(
                                                    color: Colors.black26,
                                                    offset: Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                      ),
                                      if (count > 0) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.3)
                                                : Colors.black.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '$count',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Buttons - Glassmorphism
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _buildFloatingButton(
                  icon: Icons.fit_screen,
                  tooltip: 'Fit All',
                  onPressed: _fitMapToMarkers,
                ),
                const SizedBox(height: 12),
                _buildFloatingButton(
                  icon: Icons.layers,
                  tooltip: 'Legend',
                  onPressed: () {
                    setState(() {
                      _showLegend = !_showLegend;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildFloatingButton(
                  icon: Icons.refresh,
                  tooltip: 'Refresh',
                  onPressed: () {
                    _createMarkers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Map refreshed'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Legend Panel - Glassmorphism
          if (_showLegend)
            Positioned(
              bottom: 24,
              left: 16,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Legend',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showLegend = false;
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLegendItem('Flood', _getLegendColor('Flood')),
                        _buildLegendItem('Fire', _getLegendColor('Fire')),
                        _buildLegendItem('Landslide', _getLegendColor('Landslide')),
                        _buildLegendItem('Storm', _getLegendColor('Storm')),
                        _buildLegendItem('Haze', _getLegendColor('Haze')),
                        _buildLegendItem('Earthquake', _getLegendColor('Earthquake')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.3),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Tooltip(
                message: tooltip,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: Icon(
                    icon,
                    color: const Color(0xFFFF6B35),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}