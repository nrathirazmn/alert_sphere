import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/report_incident_screen.dart';
import '../screens/editProfile_screen.dart';
import '../screens/aboutAlertSphere_screen.dart';
import '../screens/helpSupport_screen.dart';
import '../screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> gradientThemes = [
    {
      'name': 'Fire Alert',
      'colors': [Color(0xFFFF6B35), Color(0xFFE63946)],
    },
    {
      'name': 'Ocean Blue',
      'colors': [Color(0xFF00F260), Color(0xFF0575E6)],
    },
    {
      'name': 'Sunset Glow',
      'colors': [Color(0xFFFFE259), Color(0xFFFFA751)],
    },
    {
      'name': 'Purple Dream',
      'colors': [Color(0xFF7F00FF), Color(0xFFE100FF)],
    },
  ];

  int selectedThemeIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showGradientPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Your Theme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...gradientThemes.asMap().entries.map((entry) {
              final index = entry.key;
              final theme = entry.value;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedThemeIndex = index);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: theme['colors']),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedThemeIndex == index
                          ? Colors.white
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedThemeIndex == index
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        theme['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

void _showBottomMenu(BuildContext context) {
  // We need context inside the function, so pass it or ensure the function is in the widget State
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.8),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Note: _showGradientPicker() is assumed to be defined in your widget class

              // --- SETTINGS (NEW PAGE) ---
              _buildMenuTile(
                Icons.settings_outlined,
                'Settings',
                () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),
              
              
              // --- HELP & SUPPORT (NEW PAGE) ---
              _buildMenuTile(
                Icons.help_outline,
                'Help & Support',
                () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                },
              ),
              
              // --- ABOUT ALERTSPHERE (NEW PAGE) ---
              _buildMenuTile(
                Icons.info_outline,
                'About AlertSphere',
                () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAlertSphereScreen()));
                },
              ),
              
              // --- LOGOUT (EXISTING LOGIC) ---
              _buildMenuTile(
                Icons.logout,
                'Logout',
                () {
                  Navigator.pop(context);
                  // Ensure AuthProvider and LoginScreen are available via imports/context
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  // Navigator.of(context).pushReplacement(
                  //   MaterialPageRoute(builder: (_) => const LoginScreen()),
                  // );
                },
                isDestructive: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFFFF6B35).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFFFF6B35),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentGradient = gradientThemes[selectedThemeIndex]['colors'] as List<Color>;

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: currentGradient,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                              onPressed: () { _showBottomMenu(context); },
                            ),
                          ],
                        ),
                      ),
                      // Profile Avatar & Info
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Hero(
                            tag: 'profile_avatar',
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? Text(
                                        authProvider.userName.isNotEmpty
                                            ? authProvider.userName[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: currentGradient[0],
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: currentGradient[0],
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        authProvider.userName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              authProvider.userRole == 'Authority'
                                  ? Icons.verified_user
                                  : Icons.people,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              authProvider.userRole,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Edit Profile Button
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                    );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: currentGradient[0],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFFFF6B35),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFFFF6B35),
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(text: 'Achievements'),
                    Tab(text: 'Badges'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAchievementsTab(),
            _buildBadgesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Motivational Empty State
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.orange.shade50.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF6B35).withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF6B35).withOpacity(0.2),
                        const Color(0xFFE63946).withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 60,
                    color: Color(0xFFFF6B35),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Start Your Journey!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Report your first incident to unlock achievements and earn rewards',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportIncidentScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Report an Incident',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Locked Achievement Cards
          _buildLockedAchievementCard(
            'First Report',
            'Submit your first incident report',
            Icons.flag,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildLockedAchievementCard(
            'Verified Contributor',
            'Get 5 reports verified by authorities',
            Icons.verified,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildLockedAchievementCard(
            'Community Hero',
            'Help 10 people with your reports',
            Icons.volunteer_activism,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildLockedAchievementCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Motivational Empty State
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.purple.shade50.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.purple.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.2),
                        Colors.pink.withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.military_tech,
                    size: 60,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Earn Badges!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Complete challenges and help your community to collect exclusive badges',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Locked Badge Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95, // Fixed overflow issue
            children: [
              _buildLockedBadge('Quick\nResponse', Icons.speed, Colors.blue),
              _buildLockedBadge('Night Owl', Icons.nightlight, Colors.indigo),
              _buildLockedBadge('Super\nHelper', Icons.volunteer_activism, Colors.red),
              _buildLockedBadge('Verified\nPro', Icons.verified, Colors.green),
              _buildLockedBadge('Team\nPlayer', Icons.people, Colors.orange),
              _buildLockedBadge('Guardian', Icons.shield, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBadge(String name, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: color.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            Icons.lock_outline,
            size: 12,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}

// Sticky Tab Bar Delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}