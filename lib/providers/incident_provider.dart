import 'package:flutter/material.dart';
import '../models/incident.dart';

class IncidentProvider extends ChangeNotifier {
  final List<Incident> _incidents = [
    Incident(
      id: '1',
      type: 'Flood',
      description: 'Heavy flooding at Jalan Raja Musa Aziz. Water level rising rapidly.',
      location: 'Taman Ipoh Jaya, Ipoh',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      urgency: 'Critical',
      status: 'Active',
      isVerified: true,
      upvotes: 24,
      comments: 8,
    ),
    Incident(
      id: '2',
      type: 'Fire',
      description: 'Small fire reported at commercial building. Fire department on site.',
      location: 'Jalan Sultan Idris Shah, Ipoh',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      urgency: 'High',
      status: 'Active',
      isVerified: true,
      upvotes: 15,
      comments: 3,
    ),
    Incident(
      id: '3',
      type: 'Landslide',
      description: 'Minor landslide blocking part of road. Authorities notified.',
      location: 'Jalan Kuala Kangsar, Ipoh',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      urgency: 'Medium',
      status: 'Active',
      isVerified: false,
      upvotes: 8,
      comments: 2,
    ),
    Incident(
      id: '4',
      type: 'Storm',
      description: 'Severe thunderstorm with strong winds. Trees down in several areas.',
      location: 'Taman Cempaka, Ipoh',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      urgency: 'High',
      status: 'Resolved',
      isVerified: true,
      upvotes: 32,
      comments: 12,
    ),
  ];

  List<Incident> get incidents => _incidents;

  void addIncident({
    required String type,
    required String description,
    required String location,
    required String urgency,
  }) {
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
    );

    _incidents.insert(0, newIncident);
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
}