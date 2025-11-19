import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // Import for BackdropFilter/Glassmorphism

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'New Flood Alert',
        'body': 'Heavy flooding reported in Taman Ipoh Jaya',
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'type': 'critical',
        'read': false,
      },
      {
        'title': 'Incident Verified',
        'body': 'Your landslide report has been verified by authorities',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'type': 'success',
        'read': false,
      },
      {
        'title': 'Storm Warning',
        'body': 'Severe thunderstorm expected in your area',
        'time': DateTime.now().subtract(const Duration(hours: 5)),
        'type': 'warning',
        'read': true,
      },
      {
        'title': 'Community Update',
        'body': 'New shelter location added near your area',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'type': 'info',
        'read': true,
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true, // Crucial for transparent AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Match AlertSphere style
        elevation: 0,
        foregroundColor: Colors.black, 
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Add mark all read logic here
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white70), // Lightened text for AppBar
            ),
          ),
        ],
      ),
      body: Container(
        // AlertSphere Background Gradient
        decoration: BoxDecoration(
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
        child: notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                // Add padding to push content below the transparent AppBar
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  // PASSING THE INDEX TO THE CARD
                  return _buildNotificationCard(notification, context, index);
                },
              ),
      ),
    );
  }

  // Helper functions used in the card
  Color _getTypeColor(String? type) {
    switch (type) {
      case 'critical':
        return const Color(0xFFD32F2F); // Dark Red
      case 'warning':
        return Colors.orange.shade700;
      case 'success':
        return Colors.green.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'critical':
        return Icons.sos;
      case 'warning':
        return Icons.error_outline;
      case 'success':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  String _formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, y').format(time);
    }
  }
  
  // --- Glassmorphism Notification Card ---
  // MODIFIED TO ACCEPT INDEX
  Widget _buildNotificationCard(Map<String, dynamic> notification, BuildContext context, int index) {
    final color = _getTypeColor(notification['type'] as String?);
    final bool isRead = notification['read'] as bool? ?? true;
    
    // CONDITIONALLY INCREASE MARGIN FOR THE FIRST CARD (index 0)
    final double bottomMargin = index == 0 ? 30.0 : 12.0; 

    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        // Glassmorphism background effect (unifying the style)
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(isRead ? 0.2 : 0.4), // Unread is slightly brighter
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.white.withOpacity(0.3) : color.withOpacity(0.5), // Highlight unread border
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
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // The blur effect
          child: InkWell(
            onTap: () {
              // Handle notification tap logic
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Area
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTypeIcon(notification['type'] as String?),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'] as String,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['body'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatNotificationTime(notification['time'] as DateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Unread Indicator
                  if (!isRead)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B35), // AlertSphere orange/red
                          shape: BoxShape.circle,
                        ),
                      ),
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