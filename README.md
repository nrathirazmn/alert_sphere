# 🚨 AlertSphere - Community Disaster Monitoring App

## 📖 Table of Contents

- [About](#about)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [API Integration](#api-integration)


## 🌟 About

**AlertSphere** is a community-driven disaster monitoring and emergency response application designed to keep communities informed and safe during natural disasters and emergencies. Built with Flutter, the app provides real-time incident tracking, emergency SOS features, and location-based disaster alerts.

### Why AlertSphere?

- 🌍 **Real-time Updates**: Live disaster data from ReliefWeb API
- 📍 **Location-Based**: GPS-powered incident mapping with real coordinates
- 🆘 **Emergency SOS**: Instant distress signal broadcasting
- 👥 **Community-Driven**: User-reported incidents with verification system
- 🗺️ **Interactive Maps**: Visual disaster tracking with Google Maps integration
- 🌤️ **Weather Integration**: Live weather conditions for your location

---

## ✨ Features

### Core Features

#### 🏠 Home Dashboard
- **Welcome Card**: Personalized user greeting with role-based access
- **Live Weather Widget**: Real-time weather conditions with location data
- **Quick Actions Grid**: 
  - Emergency SOS
  - Report Incident
  - View Achievements
  - Live Incident Feed
- **Top 3 Incidents**: Sorted by urgency and recency
- **Pull-to-Refresh**: Update data with a simple swipe

#### 🗺️ Interactive Map
- Real-time incident markers with GPS coordinates
- Color-coded markers by disaster type:
  - 🔵 Flood (Blue)
  - 🔴 Fire (Red)
  - 🟠 Landslide (Orange)
  - 🟣 Storm (Purple)
  - ⚫ Haze (Gray)
  - 🔴 Earthquake (Pink)
- Filter incidents by type
- Incident counter and live badge
- Auto-fit camera to show all incidents
- Toggleable legend panel
- Glassmorphism UI design

#### 🆘 Emergency SOS
- **One-Tap Distress Signal**: Send emergency broadcast instantly
- **Emergency Type Selection**: Medical, Trapped, Injured, Lost, Fire, Flood
- **Optional Message**: Add situation details
- **Emergency Hotlines**: Quick access to:
  - 999 - Emergency Services
  - 991 - Fire & Rescue (Bomba)
  - 994 - Civil Defence
  - 1-300-22-5000 - Disaster Hotline
- **Safety Tips**: In-app safety guidance
- **Animated SOS Button**: Pulse effect for urgency

#### 📢 Report Incident
- Quick incident reporting
- Camera integration for photo evidence
- Location tagging
- Urgency level selection
- Community verification system

#### 🔔 Notifications & Alerts
- Real-time disaster alerts
- Incident verification notifications
- Storm warnings
- Community updates
- Notification badge indicators

#### 👤 User Profile
- Personal information management
- Achievement badges
- Contribution tracking
- Settings and preferences

---


## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **Google Maps Flutter** - Interactive mapping


### APIs & Integrations
- **ReliefWeb API** - Global disaster data
- **OpenWeatherMap API** - Weather information
- **Geolocator** - Device location services

### UI/UX Libraries
- **Backdrop Filter** - Glassmorphism effects
- **Image Picker** - Camera integration
- **Intl** - Internationalization and date formatting

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code with Flutter extension
- Google Maps API key
- OpenWeatherMap API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/nrathirazmn/alertsphere.git
   cd alertsphere
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **API Keys Configuration**
   
   Create a file `lib/config/api_keys.dart`:
   ```dart
   class ApiKeys {
     static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
     static const String openWeatherMapApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
   }
   ```

5. **Enable Google Maps**
   
   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```
   
   **iOS** (`ios/Runner/AppDelegate.swift`):
   ```swift
   import GoogleMaps
   
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   └── incident.dart                  # Incident model with coordinates
├── providers/                         # State management
│   ├── auth_provider.dart            # Authentication state
│   └── incident_provider.dart        # Incident data management
├── screens/                           # main UI screens
│   ├── home_screen.dart              # Main dashboard
│   ├── map_screen.dart               # Interactive map
│   ├── emergency_sos_screen.dart     # SOS functionality
│   ├── report_incident_screen.dart   # Incident reporting
│   ├── notifications_screen.dart     # Alerts and notifications
│   ├── profile_screen.dart           # User profile
│   └── livefeed_screen.dart          # All incidents feed
├── services/                          # External service integrations
│   ├── reliefweb_service.dart        # ReliefWeb API integration
│   ├── weather_service.dart          # Weather API integration
│   └── geocoding_service.dart        # Location to coordinates
│   └── ai_service.dart               # ai services used
├── widgets/                           # Reusable widgets
│   └── incident_card.dart            # Incident display card
└── config/                            # Configuration files
    └── api_keys.dart                 # API key storage
```

---

## 🌐 API Integration

### ReliefWeb API

The app fetches real-time disaster data from ReliefWeb:

```dart
// Example usage
final incidents = await ReliefWebService.fetchDisasterIncidents(
  country: 'Malaysia',
  disasterTypes: ['Flood', 'Storm', 'Earthquake'],
  limit: 50,
);
```

**Features:**
- Dynamic filtering by country and disaster type
- Automatic geocoding of incident locations
- Real-time data updates
- Fallback data when offline

### OpenWeatherMap API

Live weather data integration:

```dart
// Example usage
final weatherData = await WeatherService().getWeather(
  latitude: 3.1390,
  longitude: 101.6869,
);
```

### Geocoding Service

Converts location names to GPS coordinates:

```dart
// Example usage
final coords = await GeocodingService.getCoordinates('Kuala Lumpur');
// Returns: {latitude: 3.1390, longitude: 101.6869}
```

---

## 🎨 Design System

### Color Palette

```dart
Primary: Color(0xFFFF6B35)  // Vibrant Orange
Secondary: Color(0xFFE63946) // Red
Accent: Color(0xFFFF9F1C)   // Yellow-Orange

Disaster Types:
- Flood: Color(0xFF2196F3)      // Blue
- Fire: Color(0xFFF44336)       // Red
- Landslide: Color(0xFFFF9800)  // Orange
- Storm: Color(0xFF9C27B0)      // Purple
- Haze: Color(0xFF607D8B)       // Gray
- Earthquake: Color(0xFFE91E63) // Pink
```

### Typography

- **Headers**: Bold, 24px
- **Subheaders**: Bold, 18px
- **Body**: Regular, 16px
- **Captions**: Regular, 12px

### UI Components

- **Glassmorphism**: Frosted glass effect with backdrop blur
- **Rounded Corners**: 20-24px border radius
- **Shadows**: Elevated cards with soft shadows
- **Animations**: Smooth transitions and pulse effects

---

## 🔐 Security & Privacy

- ✅ Location permissions requested with clear explanations
- ✅ No personal location data stored without consent
- ✅ Emergency contacts handled securely

---

## 📊 Data Flow

```
User Action → Provider → Service → API → Response
                ↓                           ↓
           UI Update ← State Update ← Data Processing
```

1. User interacts with UI
2. Provider manages state
3. Service handles API calls
4. Data is processed and validated
5. State is updated
6. UI reflects changes

---

## Limitations

- **No backend integration:** The app currently does not connect to any backend server or database. All data is static or locally stored within the app.
- **No caching mechanism** - App requires active internet connection for most features
- **API rate limiting** - Dependent on external API quotas and availability
- **SOS not connected to authorities** - Emergency signals are simulated, not actually sent to 999
- **No two-way communication** - Users can't receive responses from emergency services

## Future Works

- **Backend Integration** Handling the backend (user authentication, local updates) through Firebase
- **Improved Security Feature** Allows authorities to auto locate and last geo-coordinate is sent out to all registered emergency contacts
- **Inclusive Support** Offline and supporting multi-lingual option



## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Check code coverage
flutter test --coverage
```

## Running the App

### Debug Mode
To run the app in debug mode (useful for development and testing):

```bash
flutter run

```
### Releasing an apk 
Command to release and where to find

```bash

flutter build apk --release

build/app/outputs/flutter-apk/app-release.apk


