import 'card.dart';

enum PlayerType { human, ai }

class Player {
  final String id;
  final String name;
  final PlayerType type;
  List<CardModel> hand;
  bool isLandlord;

  Player({
    required this.id,
    required this.name,
    required this.type,
    this.hand = const [],
    this.isLandlord = false,
  });

  void sortHand() => hand.sort();

  @override
  String toString() => 'Player{name: $name, hand: $hand}';
}