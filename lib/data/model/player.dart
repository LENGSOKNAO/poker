import 'package:game_poker/data/model/card_model.dart';

class Player {
  String name;
  List<CardModel> card = [];
  double chips;
  bool isAI;
  double currentBet = 0;

  Player({required this.name, required this.chips, this.isAI = false});
}
