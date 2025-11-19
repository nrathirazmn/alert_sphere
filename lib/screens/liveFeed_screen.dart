import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../providers/incident_provider.dart';

class LiveFeedScreen extends StatefulWidget {
  const LiveFeedScreen({super.key});

  @override
  State<LiveFeedScreen> createState() => _LiveFeedScreenState();
}

class _LiveFeedScreenState extends State<LiveFeedScreen> {
  // State for filtering
  String _selectedFilter = 'All'; 
  String _selectedSort = 'Recent';
  final List<String> _filters = ['All', 'Flood', 'Haze', 'Fire', 'Landslide'];
  final List<String> _sortOptions = ['Recent', 'Urgency (High to Low)'];

  // Helper functions (copied from HomeScreen)
  Color _getIncidentColor(String type) {
    switch (type.toLowerCase()) {
      case 'flood': return const Color(0xFF2196F3);
      case 'fire': return const Color(0xFFF44336);
      case 'landslide': return const Color(0xFF795548);
      case 'haze': return const Color(0xFF607D8B);
      default: return const Color(0xFFFF6B35);
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical': return const Color(0xFFD32F2F);
      case 'high': return const Color(0xFFFF6F00);
      case 'medium': return const Color(0xFFFBC02D);
      default: return const Color(0xFF388E3C);
    }
  }
  
  // Logic to filter and sort the list
  List<Incident> _getFilteredAndSortedIncidents(IncidentProvider provider) {
    List<Incident> incidents = provider.incidents.where((incident) {
      if (_selectedFilter == 'All') return true;
      return incident.type == _selectedFilter;
    }).toList();

    if (_selectedSort == 'Recent') {
      incidents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (_selectedSort == 'Urgency (High to Low)') {
      // Simple Urgency sorting: Critical (4) > High (3) > Medium (2) > Low (1)
      int getUrgencyRank(String urgency) {
        switch (urgency.toLowerCase()) {
          case 'critical': return 4;
          case 'high': return 3;
          case 'medium': return 2;
          default: return 1;
        }
      }
      incidents.sort((a, b) => getUrgencyRank(b.urgency).compareTo(getUrgencyRank(a.urgency)));
    }
    return incidents;
  }

  @override
  Widget build(BuildContext context) {
    final incidentProvider = Provider.of<IncidentProvider>(context);
    final filteredIncidents = _getFilteredAndSortedIncidents(incidentProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Live Incident Feed',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          // AlertSphere Background Gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B35).withOpacity(0.1),
              const Color(0xFFE63946).withOpacity(0.05),
              const Color(0xFFFF9F1C).withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            // Filter and Sort Bar
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: Row(
                children: [
                  Expanded(child: _buildFilterDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSortDropdown()),
                ],
              ),
            ),
            
            // Incident List
            Expanded(
              child: filteredIncidents.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredIncidents.length,
                      itemBuilder: (context, index) {
                        return _buildIncidentCard(filteredIncidents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Filter and Sort Dropdowns ---
  Widget _buildFilterDropdown() {
    return _buildDropdownWrapper(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isExpanded: true,
          icon: const Icon(Icons.filter_list, color: Colors.black54),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onChanged: (String? newValue) {
            setState(() {
              _selectedFilter = newValue!;
            });
          },
          items: _filters.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text('Filter by: $value'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return _buildDropdownWrapper(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSort,
          isExpanded: true,
          icon: const Icon(Icons.sort, color: Colors.black54),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSort = newValue!;
            });
          },
          items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text('Sort by: ${value.split(' ')[0]}'),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Helper for Dropdown Glassmorphism Styling
  Widget _buildDropdownWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: child,
        ),
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Feed is Clear!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No incidents matching your filter criteria.',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // --- Incident Card (Reused from HomeScreen) ---
  Widget _buildIncidentCard(Incident incident) {
    final color = _getIncidentColor(incident.type);
    final urgencyColor = _getUrgencyColor(incident.urgency);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () { /* Navigate to incident details */ },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Incident Type Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.3), color.withOpacity(0.2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                        ),
                        child: Text(
                          incident.type,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Urgency Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: urgencyColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: urgencyColor, width: 1.5),
                        ),
                        child: Text(
                          incident.urgency.toUpperCase(),
                          style: TextStyle(
                            color: urgencyColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Verification Status
                      if (incident.isVerified)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    incident.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Location and Time Info (Simplified for brevity)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          incident.location,
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}