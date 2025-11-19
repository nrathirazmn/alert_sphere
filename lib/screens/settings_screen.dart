import 'package:flutter/material.dart';
import 'dart:ui';
import 'emergencyContacts_screen.dart';
import 'changePass_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- Local States for Toggles ---
  bool _criticalAlertsEnabled = true;
  bool _hazeUpdatesEnabled = false;
  bool _locationTrackingEnabled = true; // Initial state

  // Placeholder for requesting location permission
  Future<void> _requestLocationPermission() async {
    // In a real app, you would use geolocator/permission_handler here.
    // Example logic using Flutter built-in concepts:
    if (!_locationTrackingEnabled) {
      // Simulate permission request
      final bool granted = await Future.delayed(
        const Duration(milliseconds: 500),
        () => true, // Assume granted for the demo
      );

      if (mounted) {
        setState(() {
          _locationTrackingEnabled = granted;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(granted ? 'Location access granted!' : 'Location access denied.'),
            backgroundColor: granted ? Colors.green : Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        _locationTrackingEnabled = false;
      });
    }
  }

  // Navigation to the new Emergency Contacts screen
  void _manageEmergencyContacts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black, 
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
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
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
            bottom: 20,
            left: 16,
            right: 16,
          ),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Notification Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // 1. Critical Alerts Toggle
            _buildSettingsToggleCard(
              context,
              title: 'Critical Alerts',
              subtitle: 'Receive instant notifications for high-urgency events.',
              icon: Icons.notifications_active,
              color: Colors.red.shade600,
              initialValue: _criticalAlertsEnabled,
              onChanged: (value) {
                setState(() => _criticalAlertsEnabled = value);
              },
            ),
            // 2. Haze/Weather Updates Toggle
            _buildSettingsToggleCard(
              context,
              title: 'Haze/Weather Updates',
              subtitle: 'Receive low-urgency daily environmental reports.',
              icon: Icons.wb_cloudy_outlined,
              color: Colors.blueGrey.shade600,
              initialValue: _hazeUpdatesEnabled,
              onChanged: (value) {
                setState(() => _hazeUpdatesEnabled = value);
              },
            ),
            
            // 3. Location Tracking Toggle (Uses custom request function)
            _buildSettingsToggleCard(
              context,
              title: 'Allow Location Tracking',
              subtitle: 'Enable location-based alerts (Recommended).',
              icon: Icons.location_on_outlined,
              color: Colors.green.shade600,
              initialValue: _locationTrackingEnabled,
              onChanged: (value) {
                if (value) {
                  _requestLocationPermission();
                } else {
                  // Simply turn it off
                  setState(() => _locationTrackingEnabled = false);
                }
              },
            ),
            
            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 16),
              child: Text(
                'Security & Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // 4. Emergency Contacts Action
            _buildSettingsActionCard(
              context,
              title: 'Emergency Contacts',
              subtitle: 'Manage up to 5 emergency contacts.',
              icon: Icons.group_outlined,
              color: Colors.orange.shade700,
              onTap: _manageEmergencyContacts, // Navigation implemented
            ),
            // 5. Change Password Action
            _buildSettingsActionCard(
              context,
              title: 'Change Password',
              subtitle: 'Update your account security credentials.',
              icon: Icons.lock_outline,
              color: Colors.blue.shade600,
              onTap: () { 
                Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );},
            ),
          ],
        ),
      ),
    );
  }
  
  // Reusable Glassmorphism Toggle Card (uses StatefulWidget properties)
  Widget _buildSettingsToggleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool initialValue,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildCardWrapper(
      context,
      color: color,
      child: SwitchListTile(
        activeColor: color,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        value: initialValue,
        onChanged: onChanged,
        secondary: Icon(icon, color: color),
      ),
    );
  }

  // Reusable Glassmorphism Action Card
  Widget _buildSettingsActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _buildCardWrapper(
      context,
      color: color,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
      ),
    );
  }
  
  // Base Glassmorphism Container Wrapper
  Widget _buildCardWrapper(BuildContext context, {required Widget child, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}