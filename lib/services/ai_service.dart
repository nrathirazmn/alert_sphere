import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Simulated AI classification using pattern matching
  // In production, this would call actual AI API
  static Future<Map<String, String>> classifyIncident(String description) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    final descLower = description.toLowerCase();

    // Simple keyword-based classification
    String type = 'Other';
    String urgency = 'Medium';

    // Type classification
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

    // Urgency classification
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

  // Method for future integration with actual AI API (OpenAI, Claude, etc.)
  static Future<Map<String, String>> classifyWithAPI(String description) async {
    try {
      // Example API call structure (replace with your actual API)
      final response = await http.post(
        Uri.parse('YOUR_AI_API_ENDPOINT'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY',
        },
        body: jsonEncode({
          'prompt': '''Analyze this disaster incident report and classify it:
          
Description: $description

Please provide:
1. Incident type (Flood, Fire, Landslide, Storm, Haze, Accident, or Other)
2. Urgency level (Critical, High, Medium, or Low)

Return as JSON: {"type": "...", "urgency": "..."}''',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'type': data['type'],
          'urgency': data['urgency'],
        };
      } else {
        throw Exception('API call failed');
      }
    } catch (e) {
      // Fallback to pattern matching
      return classifyIncident(description);
    }
  }
}