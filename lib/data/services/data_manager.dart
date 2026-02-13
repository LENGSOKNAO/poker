import 'dart:convert';
import 'package:game_poker/data/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  final String _userKey = 'game_poker';
  Map<String, User> _users = {};
  User? _currentUser;

  DataManager() {
    _userLogin();
  }

  void _userLogin() {
    final List<User> allPlayers = [
      User(
        email: 'alice@gmail.com',
        name: '1',
        pass: '1',
        profile:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&h=500&fit=crop',
        joinDate: DateTime(2024, 1, 15),
        lastLogin: DateTime(2026, 2, 1),
        balance: 1500.0,
        chips: 15000,
        level: 42,
        wins: 128,
        gamesPlayed: 350,
      ),
      User(
        email: 'bob@gmail.com',
        name: 'Bob Smith',
        pass: 'bob123',
        profile:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&h=500&fit=crop',
        joinDate: DateTime(2024, 2, 10),
        lastLogin: DateTime(2026, 2, 2),
        balance: 2500.0,
        chips: 25000,
        level: 38,
        wins: 95,
        gamesPlayed: 280,
      ),
      User(
        email: 'charlie@gmail.com',
        name: 'Charlie Brown',
        pass: 'charlie123',
        profile:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop',
        joinDate: DateTime(2024, 3, 5),
        lastLogin: DateTime(2026, 2, 3),
        balance: 3200.0,
        chips: 32000,
        level: 51,
        wins: 156,
        gamesPlayed: 410,
      ),
      User(
        email: 'diana@gmail.com',
        name: 'Diana Prince',
        pass: 'diana123',
        profile:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500&h=500&fit=crop',
        joinDate: DateTime(2024, 4, 12),
        lastLogin: DateTime(2026, 2, 4),
        balance: 1800.0,
        chips: 18000,
        level: 29,
        wins: 67,
        gamesPlayed: 198,
      ),
      User(
        email: 'eve@gmail.com',
        name: 'Eve Adams',
        pass: 'eve123',
        profile:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&h=500&fit=crop',
        joinDate: DateTime(2024, 5, 20),
        lastLogin: DateTime(2026, 2, 5),
        balance: 2100.0,
        chips: 21000,
        level: 33,
        wins: 82,
        gamesPlayed: 225,
      ),
      User(
        email: 'frank@gmail.com',
        name: 'Frank Castle',
        pass: 'frank123',
        profile:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&h=500&fit=crop',
        joinDate: DateTime(2024, 6, 15),
        lastLogin: DateTime(2026, 2, 6),
        balance: 4300.0,
        chips: 43000,
        level: 47,
        wins: 143,
        gamesPlayed: 389,
      ),
      User(
        email: 'grace@gmail.com',
        name: 'Grace Hopper',
        pass: 'grace123',
        profile:
            'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=500&h=500&fit=crop',
        joinDate: DateTime(2024, 7, 8),
        lastLogin: DateTime(2026, 2, 7),
        balance: 3700.0,
        chips: 37000,
        level: 44,
        wins: 118,
        gamesPlayed: 312,
      ),
      User(
        email: 'henry@gmail.com',
        name: 'Henry Cavill',
        pass: 'henry123',
        profile:
            'https://imgs.search.brave.com/KL3_OExvuF9hugpWhbBPf5fDEvQSxrL7A5gLIXa_b-w/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pMC53/cC5jb20vcGljanVt/Ym8uY29tL3dwLWNv/bnRlbnQvdXBsb2Fk/cy9taW5pbWFsaXN0/LXBvcnRyYWl0LW9m/LWEtd29tYW4td2l0/aC1nbG93aW5nLWxp/Z2h0LWJlaGluZC1o/ZXItZnJlZS1pbWFn/ZS5qcGVnP3c9NjAw/JnF1YWxpdHk9ODA',
        joinDate: DateTime(2024, 8, 19),
        lastLogin: DateTime(2026, 2, 8),
        balance: 5200.0,
        chips: 52000,
        level: 55,
        wins: 189,
        gamesPlayed: 478,
      ),
      User(
        email: 'isabella@gmail.com',
        name: 'Isabella Martinez',
        pass: 'isabella123',
        profile:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500&h=500&fit=crop',
        joinDate: DateTime(2024, 9, 3),
        lastLogin: DateTime(2026, 2, 9),
        balance: 2800.0,
        chips: 28000,
        level: 36,
        wins: 91,
        gamesPlayed: 267,
      ),
      User(
        email: 'jack@gmail.com',
        name: 'Jack Reacher',
        pass: 'jack123',
        profile:
            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&h=500&fit=crop',
        joinDate: DateTime(2024, 10, 25),
        lastLogin: DateTime(2026, 2, 10),
        balance: 3900.0,
        chips: 39000,
        level: 41,
        wins: 107,
        gamesPlayed: 301,
      ),
    ];

    for (var n in allPlayers) {
      _users[n.name] = n;
    }
    _currentUser = allPlayers.first;
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = json.encode(
      _users.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(_userKey, userJson);
  }

  Future<bool> login(String username, String password) async {
    final user = _users[username];
    if (user != null && user.pass == password) {
      user.joinDate == DateTime.now();
      _currentUser = user;
      await _saveUser();
      return true;
    }
    return false;
  }

  Future<List<User>> getAllUsers() async {
    return _users.values.toList();
  }

  User? get currentUser => _currentUser;

  Future<void> updateUser(User user) async {
    _users[user.name] = user;
    if (_currentUser?.name == user.name) {
      _currentUser = user;
    }
    await _saveUser();
  }
}
