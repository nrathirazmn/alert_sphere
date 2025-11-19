import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incident.dart';
import 'geocoding_service.dart';

class ReliefWebService {
  static const String baseUrl = 'https://api.reliefweb.int/v1/reports';
  
  /// Fetch disaster incidents with REAL coordinates
  static Future<List<Incident>> fetchDisasterIncidents({
    String? country,
    List<String>? disasterTypes,
    int limit = 50,
    bool useGeocoding = true, // Option to geocode locations
  }) async {
    try {
      final queryParams = {
        'appname': 'alertsphere',
        'profile': 'list',
        'preset': 'latest',
        'limit': limit.toString(),
        'fields[include]': 'title,date,primary_country,country,disaster_type,body,location', // Request location data
      };
      
      // Build filter
      Map<String, dynamic> filter = {
        'operator': 'AND',
        'conditions': [],
      };
      
      if (country != null && country.isNotEmpty) {
        filter['conditions'].add({
          'field': 'primary_country.iso3',
          'value': _getCountryCode(country),
        });
      }
      
      if (disasterTypes != null && disasterTypes.isNotEmpty) {
        filter['conditions'].add({
          'field': 'disaster_type.name',
          'value': disasterTypes,
          'operator': 'OR',
        });
      }
      
      if ((filter['conditions'] as List).isNotEmpty) {
        queryParams['filter'] = jsonEncode(filter);
      }
      
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      
      print('🌐 Calling API: $uri');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reports = data['data'] as List?;
        
        if (reports == null || reports.isEmpty) {
          print('⚠️ No incidents found, using fallback data');
          return _getFallbackIncidents();
        }
        
        print('✅ Found ${reports.length} incidents from API');
        
        List<Incident> incidents = [];
        
        for (var report in reports) {
          try {
            final fields = report['fields'];
            
            String type = _extractDisasterType(fields);
            String urgency = _extractUrgency(fields);
            String location = _extractLocation(fields);
            String description = fields['title'] ?? 'No description available';
            
            DateTime timestamp;
            try {
              timestamp = DateTime.parse(fields['date']['created']);
            } catch (e) {
              timestamp = DateTime.now();
            }
            
            // EXTRACT REAL COORDINATES
            Map<String, double>? coordinates = await _extractCoordinates(
              fields, 
              location,
              useGeocoding,
            );
            
            incidents.add(
              Incident(
                id: report['id'].toString(),
                type: type,
                description: description,
                location: location,
                timestamp: timestamp,
                urgency: urgency,
                status: 'Active',
                isVerified: true,
                upvotes: 0,
                comments: 0,
                latitude: coordinates?['latitude'],
                longitude: coordinates?['longitude'],
              ),
            );
            
            // Small delay between geocoding requests to avoid rate limiting
            if (useGeocoding) {
              await Future.delayed(const Duration(milliseconds: 200));
            }
            
          } catch (e) {
            print('⚠️ Error parsing incident: $e');
            continue;
          }
        }
        
        print('🎉 Successfully parsed ${incidents.length} incidents');
        print('📍 ${incidents.where((i) => i.hasCoordinates).length} have real coordinates');
        
        if (incidents.isEmpty) {
          return _getFallbackIncidents();
        }
        
        return incidents;
      } else {
        print('❌ API Error: ${response.statusCode}');
        return _getFallbackIncidents();
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
      return _getFallbackIncidents();
    }
  }
  
  /// Extract coordinates from API data or geocode location
  static Future<Map<String, double>?> _extractCoordinates(
    Map<String, dynamic> fields,
    String location,
    bool useGeocoding,
  ) async {
    // 1. Check if API provides coordinates directly (some reports have this)
    if (fields['location'] != null && fields['location'] is List) {
      for (var loc in fields['location']) {
        if (loc['lat'] != null && loc['lon'] != null) {
          return {
            'latitude': double.parse(loc['lat'].toString()),
            'longitude': double.parse(loc['lon'].toString()),
          };
        }
      }
    }
    
    // 2. Try Malaysia region lookup (fast, no API calls)
    final regionCoords = GeocodingService.getMalaysiaRegionCoordinates(location);
    if (regionCoords != null) {
      print('📍 Found coordinates for $location (Malaysia regions)');
      return regionCoords;
    }
    
    // 3. Use geocoding service as last resort
    if (useGeocoding && location.isNotEmpty && location != 'Global') {
      print('🔍 Geocoding: $location');
      final coords = await GeocodingService.getCoordinates(location);
      if (coords != null) {
        print('📍 Found coordinates for $location via geocoding');
        return coords;
      }
    }
    
    print('⚠️ No coordinates found for: $location');
    return null;
  }
  
  static String _getCountryCode(String country) {
    final countryMap = {
      'Malaysia': 'MYS',
      'Indonesia': 'IDN',
      'Philippines': 'PHL',
      'Thailand': 'THA',
      'Singapore': 'SGP',
      'Vietnam': 'VNM',
      'Myanmar': 'MMR',
      'Cambodia': 'KHM',
      'Laos': 'LAO',
      'Brunei': 'BRN',
    };
    
    return countryMap[country] ?? country;
  }
  
  static String _extractDisasterType(Map<String, dynamic> fields) {
    if (fields['disaster_type'] != null && (fields['disaster_type'] as List).isNotEmpty) {
      final disasterName = fields['disaster_type'][0]['name'].toString().toLowerCase();
      
      if (disasterName.contains('flood')) return 'Flood';
      if (disasterName.contains('fire') || disasterName.contains('wildfire')) return 'Fire';
      if (disasterName.contains('landslide') || disasterName.contains('mudslide')) return 'Landslide';
      if (disasterName.contains('storm') || disasterName.contains('cyclone') || disasterName.contains('typhoon')) return 'Storm';
      if (disasterName.contains('earthquake')) return 'Earthquake';
      if (disasterName.contains('haze')) return 'Haze';
    }
    
    final title = (fields['title'] ?? '').toString().toLowerCase();
    if (title.contains('flood')) return 'Flood';
    if (title.contains('fire')) return 'Fire';
    if (title.contains('landslide')) return 'Landslide';
    if (title.contains('storm') || title.contains('typhoon')) return 'Storm';
    if (title.contains('earthquake')) return 'Earthquake';
    if (title.contains('haze')) return 'Haze';
    
    return 'Other';
  }
  
  static String _extractUrgency(Map<String, dynamic> fields) {
    final title = (fields['title'] ?? '').toString().toLowerCase();
    final body = (fields['body'] ?? '').toString().toLowerCase();
    final combined = '$title $body';
    
    if (combined.contains('severe') || 
        combined.contains('critical') || 
        combined.contains('emergency') ||
        combined.contains('catastrophic')) {
      return 'Critical';
    }
    
    if (combined.contains('major') || 
        combined.contains('significant') ||
        combined.contains('serious')) {
      return 'High';
    }
    
    if (combined.contains('minor') || 
        combined.contains('small')) {
      return 'Low';
    }
    
    return 'Medium';
  }
  
  static String _extractLocation(Map<String, dynamic> fields) {
    if (fields['primary_country'] != null) {
      String country = fields['primary_country']['name'] ?? '';
      String title = fields['title'] ?? '';
      String specificLocation = _extractLocationFromTitle(title);
      
      if (specificLocation.isNotEmpty && specificLocation != country) {
        return '$specificLocation, $country';
      }
      
      return country;
    }
    
    if (fields['country'] != null && (fields['country'] as List).isNotEmpty) {
      return fields['country'][0]['name'] ?? 'Unknown Location';
    }
    
    return 'Global';
  }
  
  static String _extractLocationFromTitle(String title) {
    final words = title.split(' ');
    for (var word in words) {
      if (word.isNotEmpty && word[0] == word[0].toUpperCase()) {
        if (!['The', 'A', 'An', 'In', 'On', 'At', 'To', 'From', 'For', 'With', 'By'].contains(word)) {
          return word;
        }
      }
    }
    return '';
  }
  
  static List<Incident> _getFallbackIncidents() {
    print('📦 Using fallback data with REAL coordinates');
    final now = DateTime.now();
    
    return [
      Incident(
        id: 'fallback_1',
        type: 'Flood',
        description: 'Heavy rainfall causing flash floods in low-lying areas.',
        location: 'Kuala Lumpur, Malaysia',
        timestamp: now.subtract(const Duration(hours: 2)),
        urgency: 'High',
        status: 'Active',
        isVerified: true,
        upvotes: 15,
        comments: 5,
        latitude: 3.1390,
        longitude: 101.6869,
      ),
      Incident(
        id: 'fallback_2',
        type: 'Storm',
        description: 'Tropical storm approaching coastal regions.',
        location: 'Penang, Malaysia',
        timestamp: now.subtract(const Duration(hours: 4)),
        urgency: 'Critical',
        status: 'Active',
        isVerified: true,
        upvotes: 23,
        comments: 8,
        latitude: 5.4164,
        longitude: 100.3327,
      ),
      Incident(
        id: 'fallback_3',
        type: 'Haze',
        description: 'Air quality deteriorating. Stay indoors.',
        location: 'Selangor, Malaysia',
        timestamp: now.subtract(const Duration(hours: 5)),
        urgency: 'Medium',
        status: 'Active',
        isVerified: true,
        upvotes: 8,
        comments: 2,
        latitude: 3.0738,
        longitude: 101.5183,
      ),
      Incident(
        id: 'fallback_4',
        type: 'Landslide',
        description: 'Soil erosion on hillside area. Road closures in effect.',
        location: 'Cameron Highlands, Malaysia',
        timestamp: now.subtract(const Duration(hours: 8)),
        urgency: 'High',
        status: 'Active',
        isVerified: true,
        upvotes: 12,
        comments: 3,
        latitude: 4.4703,
        longitude: 101.3777,
      ),
      Incident(
        id: 'fallback_5',
        type: 'Fire',
        description: 'Forest fire contained but monitoring continues.',
        location: 'Johor, Malaysia',
        timestamp: now.subtract(const Duration(hours: 12)),
        urgency: 'Low',
        status: 'Monitoring',
        isVerified: true,
        upvotes: 6,
        comments: 1,
        latitude: 1.4854,
        longitude: 103.7618,
      ),
    ];
  }
}