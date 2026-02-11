// data/model/user.dart
class User {
  final String email;
  final String name;
  final String pass;
  final String? profile;
  final DateTime joinDate;
  DateTime lastLogin;
  double balance;
  int chips;
  int level;
  int wins;
  int gamesPlayed;

  User({
    required this.email,
    required this.name,
    required this.pass,
    this.profile,
    required this.joinDate,
    required this.lastLogin,
    this.balance = 1000.0,
    this.chips = 10000,
    this.level = 1,
    this.wins = 0,
    this.gamesPlayed = 0,
  });

  double get winRate => gamesPlayed > 0 ? (wins / gamesPlayed) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'pass': pass,
    'profile': profile,
    'joinDate': joinDate.toIso8601String(),
    'lastLogin': lastLogin.toIso8601String(),
    'balance': balance,
    'chips': chips,
    'level': level,
    'wins': wins,
    'gamesPlayed': gamesPlayed,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json['email'],
    name: json['name'],
    pass: json['pass'],
    profile: json['profile'],
    joinDate: DateTime.parse(json['joinDate']),
    lastLogin: DateTime.parse(json['lastLogin']),
    balance: json['balance']?.toDouble() ?? 1000.0,
    chips: json['chips'] ?? 10000,
    level: json['level'] ?? 1,
    wins: json['wins'] ?? 0,
    gamesPlayed: json['gamesPlayed'] ?? 0,
  );
}
