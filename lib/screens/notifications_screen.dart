import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
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
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification, context);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, BuildContext context) {
    Color getTypeColor() {
      switch (notification['type']) {
        case 'critical':
          return Colors.red;
        case 'warning':
          return Colors.orange;
        case 'success':
          return Colors.green;
        default:
          return Colors.blue;
      }
    }

    IconData getTypeIcon() {
      switch (notification['type']) {
        case 'critical':
          return Icons.warning;
        case 'warning':
          return Icons.error_outline;
        case 'success':
          return Icons.check_circle_outline;
        default:
          return Icons.info_outline;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: notification['read'] ? Colors.white : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['read'] ? Colors.grey.shade200 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: getTypeColor().withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            getTypeIcon(),
            color: getTypeColor(),
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification['body']),
            const SizedBox(height: 8),
            Text(
              _formatNotificationTime(notification['time']),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: !notification['read']
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B35),
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {},
      ),
    );
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
}