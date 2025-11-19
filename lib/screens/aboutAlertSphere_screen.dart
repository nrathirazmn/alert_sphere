import 'package:flutter/material.dart';
import 'dart:ui';
// import 'package:package_info_plus/package_info_plus.dart'; // Uncomment if using real package info

class AboutAlertSphereScreen extends StatelessWidget {
  const AboutAlertSphereScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder for version info
    const String appVersion = '1.0.MVP-AI';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'About AlertSphere',
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
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 40,
            bottom: 20,
            left: 30,
            right: 30,
          ),
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 80,
                    color: Color(0xFFFF6B35),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AlertSphere Hub',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version $appVersion',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            
            _buildInfoCard(context, 
              title: "Mission Statement", 
              content: "To provide the Malaysian community with a decentralized, AI-enhanced platform for real-time disaster reporting and safety information, bridging the gap between citizens and authorities during critical moments.", 
              color: Colors.red.shade400
            ),
            
            _buildInfoCard(context, 
              title: "Technology Used", 
              content: "Built with Flutter for cross-platform support. Leverages AI/LLM technology for instant incident classification and urgency scoring.", 
              color: Colors.blue.shade400
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2025 CelcomDigi x MVP Team',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Made with ❤️ for Malaysia',
                style: TextStyle(fontSize: 12, color: Colors.red.shade300),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Info Card with Glassmorphism
  Widget _buildInfoCard(BuildContext context, {required String title, required String content, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Divider(color: Colors.white38, height: 20),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}