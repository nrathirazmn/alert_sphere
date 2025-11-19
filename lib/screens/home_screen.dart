import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; // Provides the real Position class
import 'dart:ui';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../models/incident.dart';
import 'report_incident_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'emergencySOS_screen.dart'; 
import 'liveFeed_screen.dart'; 
import '../services/weather_service.dart'; // Provides the real WeatherService class


// NOTE: If you still get errors, ensure the placeholder code above this line 
// (which you must delete) is completely gone from your physical file.

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; 
  AnimationController? _fabController;
  Animation<double>? _fabAnimation;
  
  // STATE: Placeholder for live weather data
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _initDataAndAnimation();
  }
  
  // CONSOLIDATED INITIALIZATION METHOD
  Future<void> _initDataAndAnimation() async {
    // 1. Initialize Animation Controller
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController!,
      curve: Curves.easeInOut,
    );
    _fabController!.forward();

    // 2. Load Incident Data
    Future.microtask(() {
        Provider.of<IncidentProvider>(context, listen: false).loadIncidents();
    });
    
    await _loadWeather(); 
  }


  // --- Live Weather Integration (FIXED) ---
  Future<void> _loadWeather() async {
    // We must rely on the imported classes and methods here.
    try {
        // 1. Check/Request Permission
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
            permission = await Geolocator.requestPermission();
            
            if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
                if (mounted) {
                    setState(() => _weatherData = null);
                    print("Location permission denied. Cannot fetch live weather.");
                }
                return;
            }
        }
        
        // 2. Get Live Position
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);

        // 3. Fetch Weather from API
        // NOTE: Uses the correct instance of WeatherService().getWeather(lat, lon)
        final data = await WeatherService().getWeather(
            position.latitude, 
            position.longitude 
        );

        if (mounted) {
            setState(() {
                _weatherData = data; 
            });
        }
    } catch (e) {
        print("Final Weather loading error: $e");
        if(mounted) {
            setState(() {
                _weatherData = null; 
            });
        }
    }
}


  @override
  void dispose() {
    _fabController?.dispose();
    super.dispose();
  }

  // --- Utility Functions for Navigation ---

  void _onNotificationTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _onReportTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
    );
  }

  void _onSosTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencySOSScreen()),
    );
  }

  void _onLiveFeedTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LiveFeedScreen()),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }
  
  // Helper to determine Urgency Rank for sorting (Critical > High > Medium > Low)
  int _getUrgencyRank(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical': return 4;
      case 'high': return 3;
      case 'medium': return 2;
      default: return 1;
    }
  }

  // NEW HELPER: Fetches and sorts the top 3 incidents for the dashboard
  List<Incident> _getTopIncidents(IncidentProvider provider) {
    if (provider.incidents.isEmpty) return [];

    final sortedIncidents = List<Incident>.from(provider.incidents);
    sortedIncidents.sort((a, b) {
      final urgencyComparison = _getUrgencyRank(b.urgency).compareTo(_getUrgencyRank(a.urgency));
      if (urgencyComparison != 0) return urgencyComparison;
      return b.timestamp.compareTo(a.timestamp);
    });

    return sortedIncidents.take(3).toList();
  }
  
  // NEW HELPER: Maps weather condition to a local GIF asset path
  IconData _getWeatherIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('rain') || lower.contains('shower') || lower.contains('storm')) {
      return Icons.thunderstorm;
    } else if (lower.contains('sun') || lower.contains('clear')) {
      return Icons.wb_sunny;
    } else if (lower.contains('haze') || lower.contains('smoke')) {
      return Icons.air;
    } else if (lower.contains('cloud')) {
      return Icons.cloud;
    } else {
      return Icons.wb_cloudy;
    }
  }

  // NEW HELPER: Maps weather condition to a local weather pic
  String _getWeatherGif(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('rain') || lower.contains('shower') || lower.contains('storm')) {
      return 'assets/rain.png';
    } else if (lower.contains('sun') || lower.contains('clear')) {
      return 'assets/sunny.png';
    } else if (lower.contains('haze') || lower.contains('smoke')) {
      return 'assets/haze.png';
    } else if (lower.contains('cloud')) {
      return 'assets/cloudy.png';
    } else {
      return 'assets/default.png';
    }
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final incidentProvider = Provider.of<IncidentProvider>(context);

    final screens = [
      _buildHomeContent(context, authProvider, incidentProvider), // Index 0
      const MapScreen(),                                          // Index 1
      const ProfileScreen(),                                      // Index 2
    ];

    final bool isHomeScreen = _selectedIndex == 0;
    
    return Scaffold(
      extendBodyBehindAppBar: isHomeScreen,
      appBar: isHomeScreen
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              title: Row( 
                mainAxisSize: MainAxisSize.min, 
                children: [
                    Image.asset( 
                        'assets/Logo_AlertSphere.png', 
                        height: 70, 
                        fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 1), 
                    const Text(
                        'AlertSphere', 
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color.fromARGB(255, 85, 84, 84), 
                        ),
                    ),
                ],
              ), 
              actions: [
                // Notification bell (Push route, not a tab)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.black), 
                        onPressed: _onNotificationTap,
                      ),
                      // Notification badge 
                      Positioned( 
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
      
      body: Container(
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
        child: screens[_selectedIndex],
      ),
      
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped, 
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFFFF6B35),
              unselectedItemColor: Colors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  activeIcon: Icon(Icons.map),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Home Content Widget ---

  Widget _buildHomeContent(
    BuildContext context,
    AuthProvider authProvider,
    IncidentProvider incidentProvider,
  ) {
    final topIncidents = _getTopIncidents(incidentProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await incidentProvider.refreshIncidents();
        _loadWeather(); // Reload weather on refresh
      },
      color: const Color(0xFFFF6B35),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.only(top: 100),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: _buildWelcomeCard(authProvider),
            ),
          ),
          
          // --- INTEGRATION POINT 1: WEATHER CARD ---
          if (_weatherData != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildWeatherForecastCard(context), 
              ),
            ),
          // --------------------------------------------------------

          const SliverPadding(padding: EdgeInsets.only(top: 20)),
          
          // Quick Actions Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: _buildQuickActionsGrid(context),
            ),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(top: 24)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Incidents',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  GestureDetector(
                    onTap: _onLiveFeedTap, 
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(top: 20)),
          
          // --- SHOW TOP 3 INCIDENTS ---
          if (incidentProvider.isLoading)
            SliverToBoxAdapter(child: _buildLoadingState())
          else if (incidentProvider.error != null)
            SliverToBoxAdapter(child: _buildErrorState(incidentProvider))
          else if (topIncidents.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyIncidentState())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildIncidentCard(topIncidents[index]); 
                  },
                  childCount: topIncidents.length,
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  // --- NEW WIDGET: Weather Forecast Card with GIF Placeholder (FIXED LOGIC) ---
  Widget _buildWeatherForecastCard(BuildContext context) {
    if (_weatherData == null) return const SizedBox.shrink();

    final String location = _weatherData!['location'] ?? 'Location';
    final String condition = _weatherData!['condition'] ?? 'Unknown';
    final String temperature = '${_weatherData!['temperature'] ?? '--'}°C';
    final String feelsLike = '${_weatherData!['feelsLike'] ?? '--'}°C';
    
    // Get GIF asset path and Icon data
    final String gifPath = _getWeatherGif(condition);
    final IconData iconData = _getWeatherIcon(condition);
    
    // Using a dynamic color based on condition (e.g., blue for rain/clouds)
    final Color color = iconData == Icons.thunderstorm || iconData == Icons.cloud ? Colors.blue.shade600 : Colors.orange.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 20, top: 10), // Reduced top margin
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.35),
            Colors.white.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Weather GIF + Temperature
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic GIF Container
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          gifPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(iconData, color: color, size: 45), 
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      temperature,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Right Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        condition,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Feels like $feelsLike",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // --- Quick Access Widgets ---

// Fix for the Quick Actions Grid - Add childAspectRatio to control card height
  Widget _buildQuickActionsGrid(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12), 
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.95, // Controls height - lower = taller cards
          children: [
            // 1. EMERGENCY SOS (Pushed route)
            _buildActionCard(
              context,
              'Emergency SOS',
              'Send distress signal instantly',
              Icons.sos,
              const Color(0xFFD32F2F),
              _onSosTap,
            ),
            // 2. Report Incident (Pushed route)
            _buildActionCard(
              context,
              'Report Incident',
              'Fast submission via camera or text',
              Icons.add_alert,
              const Color(0xFFFF6B35),
              _onReportTap,
            ),
            // 3. Achievements (Navigates to Profile tab)
            _buildActionCard(
              context,
              'Achievements',
              'Your contributions & badges',
              Icons.stars_outlined,
              Colors.purple.shade600,
              () => setState(() => _selectedIndex = 2),
            ),
            // 4. Live Incident Feed (Pushed route to full filter page)
            _buildActionCard(
              context,
              'Live Incident',
              'Filter and view all reports',
              Icons.rss_feed,
              Colors.blue.shade600,
              _onLiveFeedTap,
            ),
          ],
        ),
      ],
    );
  }
  
  // Also update _buildActionCard to remove mainAxisAlignment: MainAxisAlignment.spaceBetween
  // Widget _buildActionCard(
  //   BuildContext context,
  //   String title,
  //   String subtitle,
  //   IconData icon,
  //   Color color,
  //   VoidCallback onTap,
  // ) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           Colors.white.withOpacity(0.4),
  //           Colors.white.withOpacity(0.2),
  //         ],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(
  //         color: Colors.white.withOpacity(0.3),
  //         width: 1.5,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: color.withOpacity(0.1),
  //           blurRadius: 15,
  //           offset: const Offset(0, 8),
  //         ),
  //       ],
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(20),
  //       child: BackdropFilter(
  //         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //         child: InkWell(
  //           onTap: onTap,
  //           borderRadius: BorderRadius.circular(20),
  //           child: Padding(
  //             padding: const EdgeInsets.all(16),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Icon at top
  //                 Container(
  //                   padding: const EdgeInsets.all(12),
  //                   decoration: BoxDecoration(
  //                     color: color.withOpacity(0.2),
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: Icon(icon, color: color, size: 32),
  //                 ),
  //                 const Spacer(), // Pushes text to bottom
  //                 // Text at bottom
  //                 Text(
  //                   title,
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.grey.shade800,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   subtitle,
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: Colors.grey.shade600,
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }  
  // --- Reusable Widgets (Error/Loading/Empty States) ---

  Widget _buildLoadingState() {
     return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFFFF6B35),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading real disaster data...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
  }
  
  Widget _buildErrorState(IncidentProvider incidentProvider) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                incidentProvider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  incidentProvider.loadIncidents();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
  }
  
  Widget _buildEmptyIncidentState() {
     return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'No active incidents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All clear in your area!',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
  }
  

  // --- All other utility widgets remain identical (e.g., _buildActionCard, _buildWelcomeCard, _getIncidentColor etc.) ---

Widget _buildActionCard(
  BuildContext context,
  String title,
  String subtitle,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  return Container(
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
        color: Colors.white.withOpacity(0.3),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // REMOVE THIS LINE: mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 12), // ADD FIXED SPACING
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B35).withOpacity(0.3),
                  const Color(0xFFE63946).withOpacity(0.3),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    authProvider.userRole == 'Authority'
                        ? Icons.verified_user
                        : Icons.person,
                    color: const Color(0xFFFF6B35),
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          authProvider.userRole == 'Authority'
                              ? '🛡️ Authority Access'
                              : '👥 Community Member',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentCard(Incident incident) {
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
            color: _getIncidentColor(incident.type).withOpacity(0.1),
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
            onTap: () {},
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getIncidentColor(incident.type).withOpacity(0.3),
                              _getIncidentColor(incident.type).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getIncidentColor(incident.type).withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIncidentIcon(incident.type),
                              size: 18,
                              color: _getIncidentColor(incident.type),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              incident.type,
                              style: TextStyle(
                                color: _getIncidentColor(incident.type),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(incident.urgency).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getUrgencyColor(incident.urgency),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          incident.urgency.toUpperCase(),
                          style: TextStyle(
                            color: _getUrgencyColor(incident.urgency),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
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
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          incident.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(incident.timestamp),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildActionChip(
                        Icons.thumb_up_outlined,
                        '${incident.upvotes}',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildActionChip(
                        Icons.comment_outlined,
                        '${incident.comments}',
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildActionChip(
                        Icons.share_outlined,
                        'Share',
                        Colors.orange,
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

  Widget _buildActionChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIncidentColor(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return const Color(0xFF2196F3);
      case 'fire':
        return const Color(0xFFF44336);
      case 'landslide':
        return const Color(0xFF795548);
      case 'storm':
        return const Color(0xFF9C27B0);
      case 'haze':
        return const Color(0xFF607D8B);
      case 'earthquake':
        return const Color(0xFFFF5722);
      case 'drought':
        return const Color(0xFFFFEB3B);
      default:
        return const Color(0xFFFF6B35);
    }
  }

  IconData _getIncidentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return Icons.water;
      case 'fire':
        return Icons.local_fire_department;
      case 'landslide':
        return Icons.landscape;
      case 'storm':
        return Icons.thunderstorm;
      case 'haze':
        return Icons.air;
      case 'earthquake':
        return Icons.vibration;
      case 'drought':
        return Icons.wb_sunny;
      default:
        return Icons.warning;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return const Color(0xFFD32F2F);
      case 'high':
        return const Color(0xFFFF6F00);
      case 'medium':
        return const Color(0xFFFBC02D);
      default:
        return const Color(0xFF388E3C);
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}