import 'package:flutter/material.dart';
import 'package:game_poker/presentation/pages/auth/login_page.dart';

class GameRoute {
  static const String login = '/login/user';
}

final Map<String, WidgetBuilder> gameRoute = {
  GameRoute.login: (context) => LoginPage(),
};
