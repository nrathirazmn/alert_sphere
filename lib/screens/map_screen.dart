import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/incident_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  static const LatLng _initialPosition = LatLng(4.5975, 101.0901); // Ipoh, Malaysia

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    final incidents = Provider.of<IncidentProvider>(context, listen: false).incidents;

    for (int i = 0; i < incidents.length; i++) {
      final incident = incidents[i];
      _markers.add(
        Marker(
          markerId: MarkerId('incident_$i'),
          position: LatLng(
            _initialPosition.latitude + (i * 0.01),
            _initialPosition.longitude + (i * 0.01),
          ),
          infoWindow: InfoWindow(
            title: incident.type,
            snippet: incident.description,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(incident.type),
          ),
        ),
      );
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
      default:
        return BitmapDescriptor.hueYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 12,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search location...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const Icon(Icons.tune, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Legend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildLegendItem(Colors.blue, 'Flood'),
                        _buildLegendItem(Colors.red, 'Fire'),
                        _buildLegendItem(Colors.orange, 'Landslide'),
                        _buildLegendItem(Colors.purple, 'Storm'),
                        _buildLegendItem(Colors.grey, 'Haze'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}