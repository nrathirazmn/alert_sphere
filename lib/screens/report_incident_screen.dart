import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:ui';
import '../providers/incident_provider.dart';
import '../services/ai_service.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({Key? key}) : super(key: key);

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  File? _image;
  bool _isAnalyzing = false;
  String? _aiClassification;
  String? _aiUrgency;
  int _currentStep = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> incidentTypes = [
    {'type': 'Flood', 'icon': Icons.water, 'color': Color(0xFF2196F3)},
    {'type': 'Fire', 'icon': Icons.local_fire_department, 'color': Color(0xFFF44336)},
    {'type': 'Landslide', 'icon': Icons.landscape, 'color': Color(0xFF795548)},
    {'type': 'Storm', 'icon': Icons.thunderstorm, 'color': Color(0xFF9C27B0)},
    {'type': 'Haze', 'icon': Icons.air, 'color': Color(0xFF607D8B)},
    {'type': 'Accident', 'icon': Icons.car_crash, 'color': Color(0xFFFF9800)},
    {'type': 'Other', 'icon': Icons.error_outline, 'color': Color(0xFF9E9E9E)},
  ];

  String? selectedType;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _analyzeWithAI() async {
    if (_descriptionController.text.isEmpty) {
      _showSnackBar('Please enter a description first', Colors.orange, Icons.warning);
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final result = await AIService.classifyIncident(_descriptionController.text);
      setState(() {
        _aiClassification = result['type'];
        _aiUrgency = result['urgency'];
        selectedType = result['type'];
        _isAnalyzing = false;
      });

      _showSnackBar(
        'AI detected: ${result['type']} (${result['urgency']} urgency)',
        Colors.green,
        Icons.check_circle,
      );
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showSnackBar('Analysis failed', Colors.red, Icons.error);
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      if (selectedType == null) {
        _showSnackBar('Please select incident type', Colors.orange, Icons.warning);
        return;
      }

      Provider.of<IncidentProvider>(context, listen: false).addIncident(
        type: selectedType!,
        description: _descriptionController.text,
        location: _locationController.text,
        urgency: _aiUrgency ?? 'Medium',
      );

      // Show success animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildSuccessDialog(),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Close screen
      });
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade400,
              Colors.green.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Report Submitted!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thank you for keeping the community safe',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: CustomScrollView(
        slivers: [
          // Stunning App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFFF6B35),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF6B35),
                      Color(0xFFE63946),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          // decoration: BoxDecoration(
                          //   color: Colors.white.withOpacity(0.2),
                          //   borderRadius: BorderRadius.circular(12),
                          // ),
                          // child: const Icon(
                          //   Icons.add_alert,
                          //   color: Colors.white,
                          //   size: 32,
                          // ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Report Incident',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Help keep your community safe',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress Indicator
                      _buildProgressIndicator(),
                      const SizedBox(height: 24),

                      // Description Section
                      _buildSectionCard(
                        title: 'What happened?',
                        icon: Icons.description_outlined,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Describe the incident in detail...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // AI Analyze Button
                            SizedBox(
                            width: double.infinity, // This makes it full width
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade400,
                                    Colors.deepPurple.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isAnalyzing ? null : _analyzeWithAI,
                                icon: _isAnalyzing
                                    ? const SizedBox(
                                        width: 28,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.psychology, size: 24),
                                label: Text(
                                  _isAnalyzing ? 'Analyzing...' : '✨ Analyze with AI',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            )),
                            if (_aiClassification != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade50,
                                      Colors.green.shade100,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.green.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'AI Classification',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$_aiClassification • $_aiUrgency urgency',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Incident Type Section
                      _buildSectionCard(
                        title: 'Incident Type',
                        icon: Icons.category_outlined,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: incidentTypes.map((incident) {
                            final isSelected = selectedType == incident['type'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedType = incident['type'];
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            incident['color'].withOpacity(0.8),
                                            incident['color'],
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? incident['color']
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: incident['color'].withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      incident['icon'],
                                      color: isSelected ? Colors.white : incident['color'],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      incident['type'],
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Location Section
                      _buildSectionCard(
                        title: 'Location',
                        icon: Icons.location_on_outlined,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                hintText: 'Enter location or address',
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: const Color(0xFFFF6B35),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a location';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12, width: 28),
                            OutlinedButton.icon(
                              onPressed: () {
                                _locationController.text = 'Ipoh, Perak, Malaysia';
                              },
                              icon: const Icon(Icons.my_location),
                              label: const Text('Use Current Location'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(
                                  color: const Color(0xFFFF6B35),
                                  width: 2,
                                ),
                                foregroundColor: const Color(0xFFFF6B35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Photo Section
                      _buildSectionCard(
                        title: 'Add Photo (Optional)',
                        icon: Icons.camera_alt_outlined,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: _image != null ? Colors.black : Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: _image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          _image!,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: GestureDetector(
                                            onTap: () => setState(() => _image = null),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6B35).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add_a_photo,
                                          size: 40,
                                          color: const Color(0xFFFF6B35),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tap to add photo',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Helps authorities assess the situation',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 57, 230, 89),
                              Color.fromARGB(255, 44, 174, 7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 0, 130, 48).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.send, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Submit Report',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: const Color(0xFFFF6B35)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your report helps keep the community safe',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35).withOpacity(0.2),
                      const Color(0xFFE63946).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF6B35),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}