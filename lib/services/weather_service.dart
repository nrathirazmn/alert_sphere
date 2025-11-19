import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // To get coordinates


const String apiKey = 'a70536f7223633049394add24daff1e8';
const String weatherApiUrl = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherService {
  // FIX: The method signature is changed to accept lat and lon (as doubles), 
  // which is a common way to define the service API.
  Future<Map<String, dynamic>?> getWeather(double lat, double lon) async {
    // Note: The Position object passed from the Home screen can be used directly, 
    // but using lat/lon primitives often simplifies service definitions.
    
    // Use Celsius units (metric)
    final uri = Uri.parse(
        '$weatherApiUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract relevant data, including 'feels_like' and using 'name' from API
        return {
          'location': data['name'],
          'temperature': data['main']['temp'].round().toString(),
          'feelsLike': data['main']['feels_like'].round().toString(), // Added feelsLike
          'condition': data['weather'][0]['description'], // Use description for GIF mapping
        };
      } else {
        print('Failed to load weather: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network error fetching weather: $e');
      return null;
    }
  }
}