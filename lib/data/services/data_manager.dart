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
        name: 'Alice Johnson',
        pass: 'alice123',
        profile:
            'https://imgs.search.brave.com/hXMLHcgARNkPqndOfX3mj_jMk9mdBZ0s-DYFLORdGw8/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjcv/NjUzLzUwMy9zbWFs/bC9wZXJzb24tdXNp/bmctdGFibGV0LWNv/bXB1dGVyLWFpLWdl/bmVyYXRlZC1waG90/by5qcGc',
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
            'https://imgs.search.brave.com/7xL7ZQnYQyXQxQxQxQxQ/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjcv/NjUzLzUwNC9zbWFs/bC9wZXJzb24tdXNp/bmctY29tcHV0ZXItYWktZ2VuZXJhdGVkLXBo/b3RvLmpwZw',
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
            'https://imgs.search.brave.com/8xL8ZQnYQyXQxQxQxQxQ/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjcv/NjUzLzUwNS9zbWFs/bC93b21hbi11c2lu/Zy1sYXB0b3AtYWkt/Z2VuZXJhdGVkLXBo/b3RvLmpwZw',
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
            'https://imgs.search.brave.com/9xL9ZQnYQyXQxQxQxQxQ/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjcv/NjUzLzUwNi9zbWFs/bC93b21hbi13aXRo/LWxhcHRvcC1haS1n/ZW5lcmF0ZWQtcGhv/dG8uanBn',
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
            'https://imgs.search.brave.com/10x10QnYQyXQxQxQxQxQ/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjcv/NjUzLzUwNy9zbWFs/bC95b3VuZy13b21h/bi13aXRoLWxhcHRv/cC1haS1nZW5lcmF0/ZWQtcGhvdG8uanBn',
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
            'https://imgs.search.brave.com/11x11QnYQyXQxQxQxQxQ/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjcv/NjUzLzUwOC9zbWFs/bC9tYW4td2l0aC1s/YXB0b3AtYWktZ2Vu/ZXJhdGVkLXBob3Rv/LmpwZw',
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
            'https://imgs.search.brave.com/12x12QnYQyXQxQxQxQxQ/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjcv/NjUzLzUwOS9zbWFs/bC93b21hbi1pbi1i/dXNpbmVzcy1haS1n/ZW5lcmF0ZWQtcGhv/dG8uanBn',
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
            'https://imgs.search.brave.com/13x13QnYQyXQxQxQxQxQ/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjcv/NjUzLzUxMC9zbWFs/bC9tYW4taW4tc3Vp/dC1haS1nZW5lcmF0/ZWQtcGhvdG8uanBn',
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
            'https://imgs.search.brave.com/14x14QnYQyXQxQxQxQxQ/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjcv/NjUzLzUxMS9zbWFs/bC93b21hbi1zbWls/aW5nLWFpLWdlbmVy/YXRlZC1waG90by5q/cGc',
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
            'https://imgs.search.brave.com/15x15QnYQyXQxQxQxQxQ/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMjcv/NjUzLzUxMi9zbWFs/bC9tYW4taW4tamFj/a2V0LWFpLWdlbmVy/YXRlZC1waG90by5q/cGc',
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
      _users[n.email] = n;
    }
    _currentUser = allPlayers.first;
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = json.encode(
      _users.map((key, value) => MapEntry(key, value.toJson())),
    );
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
}
