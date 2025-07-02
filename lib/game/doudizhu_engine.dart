import 'dart:collection';
import 'dart:math';

import '../models/deck.dart';
import '../models/player.dart';
import '../models/card.dart';

class DouDiZhuEngine {
  late final List<Player> players;
  late final Deck _deck;
  final List<CardModel> bottomCards = [];
  final Queue<Player> _turnQueue = Queue<Player>();
  Player? currentPlayer;
  List<CardModel>? lastPlayed;

  DouDiZhuEngine() {
    _init();
  }

  void _init() {
    players = [
      Player(id: 'p1', name: 'You', type: PlayerType.human),
      Player(id: 'p2', name: 'AI-1', type: PlayerType.ai),
      Player(id: 'p3', name: 'AI-2', type: PlayerType.ai),
    ];
    _deck = Deck();
    _deck.shuffle();
  }

  void start() {
    // Deal 17 cards to each player, 3 bottom cards remain.
    for (var player in players) {
      player.hand = _deck.deal(17);
      player.sortHand();
    }
    bottomCards.addAll(_deck.deal(3));

    // Simplified: first player (human) is landlord.
    players.first.isLandlord = true;
    players.first.hand.addAll(bottomCards);
    players.first.sortHand();

    _setupTurnQueue(players.first);
    currentPlayer = _turnQueue.first;
  }

  void _setupTurnQueue(Player landlord) {
    _turnQueue.clear();
    int startIdx = players.indexOf(landlord);
    for (int i = 0; i < players.length; i++) {
      _turnQueue.add(players[(startIdx + i) % players.length]);
    }
  }

  void _advanceTurn() {
    _turnQueue.add(_turnQueue.removeFirst());
    currentPlayer = _turnQueue.first;
  }

  void playCards(Player player, List<CardModel> cards) {
    if (player != currentPlayer) return;
    // TODO: Validate rules
    // Remove cards from hand
    for (var card in cards) {
      player.hand.remove(card);
    }
    lastPlayed = cards;

    if (player.hand.isEmpty) {
      // Player wins.
      // TODO: handle win.
    } else {
      _advanceTurn();
      if (currentPlayer!.type == PlayerType.ai) {
        _aiTurn();
      }
    }
  }

  void pass(Player player) {
    if (player != currentPlayer) return;
    // Passing if allowed
    _advanceTurn();
    if (currentPlayer!.type == PlayerType.ai) {
      _aiTurn();
    }
  }

  void _aiTurn() {
    // Very naive AI: plays first valid single card higher than last played single, else random.
    final ai = currentPlayer!;
    if (ai.hand.isEmpty) {
      _advanceTurn();
      return;
    }

    List<CardModel> play = [];
    if (lastPlayed == null || lastPlayed!.length != 1) {
      play = [ai.hand.first];
    } else {
      for (var card in ai.hand) {
        if (card.rank > lastPlayed!.first.rank) {
          play = [card];
          break;
        }
      }
      if (play.isEmpty) {
        pass(ai);
        return;
      }
    }

    playCards(ai, play);
  }

  Random get _random => Random();

  // Serialization for multiplayer sync
  Map<String, dynamic> toMap() {
    return {
      'players': players
          .map((p) => {
                'id': p.id,
                'hand': p.hand.map((c) => {'s': c.suit.index, 'r': c.rank}).toList(),
                'isLandlord': p.isLandlord,
              })
          .toList(),
      'bottom': bottomCards.map((c) => {'s': c.suit.index, 'r': c.rank}).toList(),
      'current': currentPlayer?.id,
      'lastPlayed': lastPlayed?.map((c) => {'s': c.suit.index, 'r': c.rank}).toList(),
    };
  }

  static DouDiZhuEngine fromMap(Map<String, dynamic> map) {
    final engine = DouDiZhuEngine();
    // Reconstruct players & hands
    engine.players.clear();
    for (var p in map['players']) {
      final player = Player(
        id: p['id'],
        name: p['id'],
        type: PlayerType.human,
        isLandlord: p['isLandlord'] ?? false,
        hand: (p['hand'] as List)
            .map<CardModel>((e) => CardModel(suit: Suit.values[e['s']], rank: e['r']))
            .toList(),
      );
      engine.players.add(player);
    }
    engine.bottomCards
        .addAll((map['bottom'] as List).map<CardModel>((e) => CardModel(suit: Suit.values[e['s']], rank: e['r'])));
    engine.currentPlayer = engine.players.firstWhere((p) => p.id == map['current']);
    if (map['lastPlayed'] != null) {
      engine.lastPlayed = (map['lastPlayed'] as List)
          .map<CardModel>((e) => CardModel(suit: Suit.values[e['s']], rank: e['r']))
          .toList();
    }
    return engine;
  }
}