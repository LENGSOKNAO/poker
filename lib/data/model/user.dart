class User {
  String name;
  String pass;
  DateTime joinDate;
  DateTime? lastLogin;

  User({
    required this.name,
    required this.pass,
    required this.joinDate,
    this.lastLogin,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pass': pass,
      'joinDate': joinDate,
      'lastLogin': lastLogin,
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      pass: json['pass'],
      joinDate: DateTime.parse(json['joinDate']),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
    );
  }
}
