import 'dart:convert';
import 'package:game_poker/data/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  final String _userKey = 'game_poker';
  Map<String, User> _users = {};
  User? _currentUser;

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = json.encode(
      _users.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(_userKey, userJson);
  }

  bool login(String username, String password) {
    final user = _users[username];
    if (user != null && user.pass == password) {
      user.joinDate == DateTime.now();
      _currentUser = user;
      _saveUser();
      return true;
    }
    return false;
  }

  User? get currentUser => _currentUser;
}
