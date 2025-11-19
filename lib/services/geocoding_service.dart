import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  // Using Nominatim (OpenStreetMap) - Free, no API key needed
  static const String baseUrl = 'https://nominatim.openstreetmap.org/search';
  
  /// Convert a location name to GPS coordinates
  static Future<Map<String, double>?> getCoordinates(String location) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'q': location,
        'format': 'json',
        'limit': '1',
      });
      
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'AlertSphere/1.0', // Nominatim requires User-Agent
        },
      );
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        
        if (data.isNotEmpty) {
          final result = data[0];
          return {
            'latitude': double.parse(result['lat']),
            'longitude': double.parse(result['lon']),
          };
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Geocoding error for $location: $e');
      return null;
    }
  }
  
  /// Get coordinates for Malaysia regions as fallback
  static Map<String, double>? getMalaysiaRegionCoordinates(String location) {
    final regionMap = {
      // Major cities
      'Kuala Lumpur': {'latitude': 3.1390, 'longitude': 101.6869},
      'Penang': {'latitude': 5.4164, 'longitude': 100.3327},
      'Johor Bahru': {'latitude': 1.4927, 'longitude': 103.7414},
      'Ipoh': {'latitude': 4.5975, 'longitude': 101.0901},
      'Melaka': {'latitude': 2.1896, 'longitude': 102.2501},
      'Kota Kinabalu': {'latitude': 5.9804, 'longitude': 116.0735},
      'Kuching': {'latitude': 1.5535, 'longitude': 110.3593},
      
      // States
      'Selangor': {'latitude': 3.0738, 'longitude': 101.5183},
      'Johor': {'latitude': 1.4854, 'longitude': 103.7618},
      'Kedah': {'latitude': 6.1184, 'longitude': 100.3681},
      'Kelantan': {'latitude': 6.1254, 'longitude': 102.2381},
      'Pahang': {'latitude': 3.8126, 'longitude': 103.3256},
      'Perak': {'latitude': 4.5921, 'longitude': 101.0901},
      'Perlis': {'latitude': 6.4449, 'longitude': 100.2048},
      'Sabah': {'latitude': 5.9788, 'longitude': 116.0753},
      'Sarawak': {'latitude': 1.5533, 'longitude': 110.3592},
      'Terengganu': {'latitude': 5.3117, 'longitude': 103.1324},
      'Negeri Sembilan': {'latitude': 2.7258, 'longitude': 101.9424},
      
      // Specific areas
      'Cameron Highlands': {'latitude': 4.4703, 'longitude': 101.3777},
      'Genting Highlands': {'latitude': 3.4231, 'longitude': 101.7933},
      'Langkawi': {'latitude': 6.3500, 'longitude': 99.8000},
    };
    
    // Try exact match first
    for (var entry in regionMap.entries) {
      if (location.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    return null;
  }
}