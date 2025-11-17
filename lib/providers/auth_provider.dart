import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String _userRole = 'Community';
  String _userName = 'User';
  bool _isLoggedIn = false;

  String get userRole => _userRole;
  String get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;

  void login(String role) {
    _userRole = role;
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