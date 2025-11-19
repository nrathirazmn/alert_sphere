import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String _userRole = 'Community';
  String _userName = 'User';
  bool _isLoggedIn = false;

  String get userRole => _userRole;
  String get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;

  // NEW METHOD: Allows external widgets (like EditProfileScreen) to update the user's name
  void updateUserName(String newName) {
    if (_userName != newName && newName.isNotEmpty) {
      _userName = newName;
      notifyListeners(); // Crucial: This updates the HomeScreen/ProfileScreen automatically
    }
  }

  void login(String role) {
    _userRole = role;
    // Note: When logging in, we set the initial placeholder name based on the role
    _userName = role == 'Authority' ? 'Officer Ahmad' : 'John Doe'; 
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userRole = 'Community';
    _userName = 'User';
    notifyListeners();
  }
}