import 'package:flutter/material.dart';
import 'package:game_poker/presentation/pages/home/main_menu_page.dart';
import 'package:game_poker/presentation/pages/auth/login_page.dart';
import 'package:game_poker/presentation/pages/game/one_vs_one.dart';

class GameRoute {
  static const String login = '/login/user';
  static const String mainHome = '/main/home';
  static const String gameOneVSOne = '/one/one';
}

final Map<String, WidgetBuilder> gameRoute = {
  GameRoute.login: (context) => LoginPage(),
  GameRoute.mainHome: (context) => MainMenuPage(),
  GameRoute.gameOneVSOne: (context) => GameOneVsOne(),
};
