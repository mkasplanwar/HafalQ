import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _username = '';

  String get username => _username;

  UserProvider() {
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    notifyListeners();
  }

  Future<void> setUsername(String newUsername) async {
    _username = newUsername;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
    notifyListeners();
  }
}
