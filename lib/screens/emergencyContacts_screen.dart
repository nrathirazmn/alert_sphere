import 'package:flutter/material.dart';
import 'dart:ui';
// IMPORT the new screen
import 'editEmergencyContact_screen.dart'; 

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  // Placeholder list of contacts
  final List<Map<String, String>> _contacts = [
    {'name': 'Mother', 'phone': '012-3456789'},
    {'name': 'Husband', 'phone': '017-9876543'},
  ];
  
  // Helper to add or update contacts upon returning from EditContactScreen
  void _saveContact(String oldName, String newName, String newPhone) {
    setState(() {
      final index = _contacts.indexWhere((c) => c['name'] == oldName);
      
      if (index != -1) {
        // Update existing contact
        _contacts[index] = {'name': newName, 'phone': newPhone};
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$newName updated successfully.')),
        );
      } else {
        // Add new contact
        _contacts.add({'name': newName, 'phone': newPhone});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$newName added successfully.')),
        );
      }
    });
  }

  // Unified navigation function for Add/Edit
  void _navigateToAddEditContact({Map<String, String>? initialContact}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContactScreen(
          initialContact: initialContact,
          // Pass the old name for identifying which contact to update in the list
          oldName: initialContact?['name'], 
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      // Result contains {'name': ..., 'phone': ..., 'oldName': ...}
      _saveContact(
        result['oldName']!, 
        result['name']!, 
        result['phone']!,
      );
    }
  }

  void _addContact() {
    _navigateToAddEditContact(); // Pass null to indicate adding a new contact
  }

  void _removeContact(int index) {
    final contactName = _contacts[index]['name'];
    setState(() {
      _contacts.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$contactName removed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (App Bar and Background remain the same)
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        //Redundant
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.person_add_alt),
        //     onPressed: _addContact,
        //   ),
        // ],
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
                'These contacts receive SOS alerts instantly.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            ..._contacts.asMap().entries.map((entry) {
              final index = entry.key;
              final contact = entry.value;
              return _buildContactCard(context, contact, index);
            }).toList(),
            
            if (_contacts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('No contacts added yet. Tap + to add one!'),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContact,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Contact'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
    );
  }

  // Glassmorphism Contact Card
  Widget _buildContactCard(BuildContext context, Map<String, String> contact, int index) {
    const Color color = Color(0xFFFF6B35); // Use the primary accent color

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
          child: ListTile(
            leading: Icon(Icons.person_pin, color: color),
            title: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
            subtitle: Text(contact['phone']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              // FIX: Use an anonymous function to ensure we pass the index correctly
              onPressed: () => _removeContact(index),
            ),
            onTap: () {
              // FIX: Navigate to edit the existing contact
              _navigateToAddEditContact(initialContact: contact); 
            },
          ),
        ),
      ),
    );
  }
}