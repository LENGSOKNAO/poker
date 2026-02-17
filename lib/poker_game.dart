import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_poker/route.dart';

class PokerGameApp extends StatelessWidget {
  const PokerGameApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: gameRoute,
      initialRoute: GameRoute.mainHome,
    );
  }
}
