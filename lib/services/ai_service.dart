import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static Future<Map<String, String>> classifyIncident(String description) async {
    await Future.delayed(const Duration(seconds: 2));

    final descLower = description.toLowerCase();

    String type = 'Other';
    String urgency = 'Medium';

    if (descLower.contains('flood') || descLower.contains('water') || descLower.contains('rain')) {
      type = 'Flood';
    } else if (descLower.contains('fire') || descLower.contains('burn') || descLower.contains('smoke')) {
      type = 'Fire';
    } else if (descLower.contains('landslide') || descLower.contains('soil') || descLower.contains('mud')) {
      type = 'Landslide';
    } else if (descLower.contains('storm') || descLower.contains('wind') || descLower.contains('thunder')) {
      type = 'Storm';
    } else if (descLower.contains('haze') || descLower.contains('air quality') || descLower.contains('pollution')) {
      type = 'Haze';
    } else if (descLower.contains('accident') || descLower.contains('crash') || descLower.contains('collision')) {
      type = 'Accident';
    }

    if (descLower.contains('severe') || descLower.contains('critical') || 
        descLower.contains('emergency') || descLower.contains('danger') ||
        descLower.contains('trapped') || descLower.contains('life-threatening')) {
      urgency = 'Critical';
    } else if (descLower.contains('major') || descLower.contains('serious') || 
               descLower.contains('heavy') || descLower.contains('rapidly')) {
      urgency = 'High';
    } else if (descLower.contains('minor') || descLower.contains('small') || 
               descLower.contains('light')) {
      urgency = 'Low';
    }

    return {
      'type': type,
      'urgency': urgency,
    };
  }
}