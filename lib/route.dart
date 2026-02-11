import 'package:flutter/material.dart';
import 'package:game_poker/presentation/home/main_menu_page.dart';
import 'package:game_poker/presentation/pages/auth/login_page.dart';

class GameRoute {
  static const String login = '/login/user';
  static const String mainHome = 'main/home';
}

final Map<String, WidgetBuilder> gameRoute = {
  GameRoute.login: (context) => LoginPage(),
  GameRoute.mainHome: (context) => MainMenuPage(),
};
