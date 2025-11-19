import 'package:flutter/material.dart';
import 'dart:ui';

class EditContactScreen extends StatefulWidget {
  final Map<String, String>? initialContact;
  final String? oldName;

  const EditContactScreen({
    Key? key,
    this.initialContact,
    this.oldName,
  }) : super(key: key);

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data or empty strings
    _nameController = TextEditingController(text: widget.initialContact?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.initialContact?['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final String newName = _nameController.text.trim();
      final String newPhone = _phoneController.text.trim();
      
      // Return the new contact data and the original name (for identification)
      Navigator.pop(context, {
        'name': newName,
        'phone': newPhone,
        'oldName': widget.oldName ?? newName, // Use newName as oldName if adding new
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialContact != null;
    const Color primaryColor = Color(0xFFFF6B35);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          isEditing ? 'Edit Contact' : 'Add New Contact',
          style: const TextStyle(
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
              primaryColor.withOpacity(0.1),
              const Color(0xFFE63946).withOpacity(0.05),
              const Color(0xFFFF9F1C).withOpacity(0.1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 40,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          child: _buildGlassmorphismForm(isEditing, primaryColor),
        ),
      ),
    );
  }

  // Helper function to build the Glassmorphism form container
  Widget _buildGlassmorphismForm(bool isEditing, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Update Contact Details' : 'New Contact Information',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: 'Name / Relation (e.g., Mother, John)',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                
                // Phone Field
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                
                // Save Button
                ElevatedButton.icon(
                  onPressed: _saveContact,
                  icon: Icon(isEditing ? Icons.save : Icons.add_circle, color: Colors.white),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Add Contact',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Text Field Widget (Styled to contrast with Glassmorphism)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
        ),
      ),
    );
  }
}