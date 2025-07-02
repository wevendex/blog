import 'dart:math';

import 'card.dart';

class Deck {
  final List<CardModel> _cards = [];

  Deck() {
    _generateDeck();
  }

  void _generateDeck() {
    _cards.clear();
    for (var suit in [Suit.spade, Suit.heart, Suit.club, Suit.diamond]) {
      for (int rank = 3; rank <= 15; rank++) {
        _cards.add(CardModel(suit: suit, rank: rank));
      }
    }
    // Add Jokers
    _cards.add(const CardModel(suit: Suit.joker, rank: 16)); // Small Joker
    _cards.add(const CardModel(suit: Suit.joker, rank: 17)); // Big Joker
  }

  void shuffle() {
    final random = Random();
    _cards.shuffle(random);
  }

  List<CardModel> deal(int count) {
    final dealt = _cards.take(count).toList();
    _cards.removeRange(0, count);
    return dealt;
  }

  bool get isEmpty => _cards.isEmpty;

  int get length => _cards.length;
}