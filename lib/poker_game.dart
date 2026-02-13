import 'package:flutter/material.dart';
import 'package:game_poker/route.dart';

class PokerGameApp extends StatelessWidget {
  const PokerGameApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: gameRoute,
      initialRoute: GameRoute.login,
    );
  }
}
