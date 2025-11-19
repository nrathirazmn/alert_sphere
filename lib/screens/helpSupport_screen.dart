import 'package:flutter/material.dart';
import 'dart:ui';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Help & Support',
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
                'Frequently Asked Questions (FAQ)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildFAQCard(context, 
              title: "How does the SOS feature work?", 
              subtitle: "Sends location data to authorities and registered contacts.",
              icon: Icons.sos, 
              color: Colors.red),
            _buildFAQCard(context, 
              title: "How is an incident verified?", 
              subtitle: "AI classification followed by official authority confirmation.",
              icon: Icons.verified_user, 
              color: Colors.green),
            _buildFAQCard(context, 
              title: "How can I find a Safe Zone?", 
              subtitle: "Use the Map tab to filter and locate the nearest approved shelter.",
              icon: Icons.map, 
              color: Colors.blue),

            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 16),
              child: Text(
                'Need More Help?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildContactCard(context, 
              title: "Chat Support (24/7)", 
              subtitle: "Connect with a live agent for assistance.",
              icon: Icons.chat_outlined, 
              color: Colors.purple,
              onTap: () {}
            ),
            _buildContactCard(context, 
              title: "Email Support", 
              subtitle: "support@alertsphere.my",
              icon: Icons.email_outlined, 
              color: Colors.teal,
              onTap: () {}
            ),
          ],
        ),
      ),
    );
  }

  // Helper for FAQ Cards (Glassmorphism List Expansion)
  Widget _buildFAQCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color}) {
    return _buildCardWrapper(
      context,
      color: color,
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 65, right: 16, bottom: 16),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Contact Cards (Glassmorphism List Action)
  Widget _buildContactCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
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

  // Base Glassmorphism Container Wrapper (Shared styling)
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