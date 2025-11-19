import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/reliefweb_service.dart';
import '../services/geocoding_service.dart';

class IncidentProvider extends ChangeNotifier {
  List<Incident> _incidents = [];
  bool _isLoading = false;
  String? _error;

  List<Incident> get incidents => _incidents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get only incidents with valid coordinates (for map display)
  List<Incident> get incidentsWithCoordinates => 
      _incidents.where((i) => i.hasCoordinates).toList();

  // Get count of incidents by type
  int getIncidentCountByType(String type) {
    if (type == 'All') return _incidents.length;
    return _incidents.where((i) => i.type == type).length;
  }

  // Get count of incidents with coordinates by type
  int getIncidentWithCoordsCountByType(String type) {
    if (type == 'All') return incidentsWithCoordinates.length;
    return incidentsWithCoordinates.where((i) => i.type == type).length;
  }

  Future<void> loadIncidents({
    String? country,
    bool useGeocoding = true,
  }) async {
    print('🔥 loadIncidents() called!');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🌐 Calling ReliefWeb API...');
      _incidents = await ReliefWebService.fetchDisasterIncidents(
        country: country ?? 'Malaysia',
        useGeocoding: useGeocoding,
      );
      print('✅ Got ${_incidents.length} incidents');
      print('📍 ${incidentsWithCoordinates.length} have coordinates');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading incidents: $e');
      _error = 'Failed to load incidents: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshIncidents({String? country}) async {
    print('🔄 Refreshing incidents...');
    await loadIncidents(country: country);
  }

  /// Add a user-reported incident with optional coordinates
  Future<void> addIncident({
    required String type,
    required String description,
    required String location,
    required String urgency,
    double? latitude,
    double? longitude,
    bool geocodeIfNeeded = true,
  }) async {
    // If coordinates not provided, try to geocode the location
    double? lat = latitude;
    double? lng = longitude;

    if (geocodeIfNeeded && lat == null && lng == null && location.isNotEmpty) {
      print('🔍 Geocoding location: $location');
      
      // Try Malaysia region lookup first (fast)
      final regionCoords = GeocodingService.getMalaysiaRegionCoordinates(location);
      if (regionCoords != null) {
        lat = regionCoords['latitude'];
        lng = regionCoords['longitude'];
        print('📍 Found coordinates via region lookup');
      } else {
        // Use geocoding service
        final coords = await GeocodingService.getCoordinates(location);
        if (coords != null) {
          lat = coords['latitude'];
          lng = coords['longitude'];
          print('📍 Found coordinates via geocoding');
        }
      }
    }

    final newIncident = Incident(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      description: description,
      location: location,
      timestamp: DateTime.now(),
      urgency: urgency,
      status: 'Active',
      isVerified: false,
      upvotes: 0,
      comments: 0,
      latitude: lat,
      longitude: lng,
    );

    _incidents.insert(0, newIncident);
    
    if (newIncident.hasCoordinates) {
      print('✅ Added incident with coordinates: $location');
    } else {
      print('⚠️ Added incident without coordinates: $location');
    }
    
    notifyListeners();
  }

  void upvoteIncident(String id) {
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index != -1) {
      _incidents[index] = _incidents[index].copyWith(
        upvotes: _incidents[index].upvotes + 1,
      );
      notifyListeners();
    }
  }

  void verifyIncident(String id) {
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index != -1) {
      _incidents[index] = _incidents[index].copyWith(
        isVerified: true,
      );
      notifyListeners();
    }
  }

  void updateIncidentStatus(String id, String status) {
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index != -1) {
      _incidents[index] = _incidents[index].copyWith(
        status: status,
      );
      notifyListeners();
    }
  }

  /// Update incident coordinates (useful if initially added without coords)
  Future<void> updateIncidentCoordinates(String id) async {
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index != -1) {
      final incident = _incidents[index];
      
      if (!incident.hasCoordinates && incident.location.isNotEmpty) {
        print('🔍 Geocoding incident: ${incident.location}');
        
        // Try region lookup first
        var coords = GeocodingService.getMalaysiaRegionCoordinates(incident.location);
        
        // Fallback to geocoding service
        if (coords == null) {
          coords = await GeocodingService.getCoordinates(incident.location);
        }
        
        if (coords != null) {
          _incidents[index] = incident.copyWith(
            latitude: coords['latitude'],
            longitude: coords['longitude'],
          );
          print('📍 Updated coordinates for: ${incident.location}');
          notifyListeners();
        }
      }
    }
  }

  /// Geocode all incidents that don't have coordinates
  Future<void> geocodeAllIncidents() async {
    print('🔍 Geocoding all incidents without coordinates...');
    
    int updated = 0;
    for (int i = 0; i < _incidents.length; i++) {
      if (!_incidents[i].hasCoordinates && _incidents[i].location.isNotEmpty) {
        // Try region lookup first
        var coords = GeocodingService.getMalaysiaRegionCoordinates(_incidents[i].location);
        
        // Fallback to geocoding service
        if (coords == null) {
          coords = await GeocodingService.getCoordinates(_incidents[i].location);
          // Small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 200));
        }
        
        if (coords != null) {
          _incidents[i] = _incidents[i].copyWith(
            latitude: coords['latitude'],
            longitude: coords['longitude'],
          );
          updated++;
        }
      }
    }
    
    print('📍 Updated $updated incidents with coordinates');
    notifyListeners();
  }

  /// Filter incidents by type
  List<Incident> getIncidentsByType(String type) {
    if (type == 'All') return _incidents;
    return _incidents.where((i) => i.type == type).toList();
  }

  /// Filter incidents by urgency
  List<Incident> getIncidentsByUrgency(String urgency) {
    return _incidents.where((i) => i.urgency == urgency).toList();
  }

  /// Get recent incidents (last 24 hours)
  List<Incident> getRecentIncidents() {
    final now = DateTime.now();
    return _incidents.where((i) {
      final difference = now.difference(i.timestamp);
      return difference.inHours < 24;
    }).toList();
  }

  /// Get critical incidents
  List<Incident> getCriticalIncidents() {
    return _incidents.where((i) => i.urgency == 'Critical').toList();
  }
}