import 'dart:collection';
import 'dart:math';

import '../models/deck.dart';
import '../models/player.dart';
import '../models/card.dart';
import 'combo.dart';

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
    final combo = analyseCombo(cards);
    if (!combo.isValid) return;

    if (lastPlayed != null) {
      final prevCombo = analyseCombo(lastPlayed!);
      if (!canBeat(combo, prevCombo)) return;
    }

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
    final ai = currentPlayer!;

    // Strategy: if starting trick -> play lowest combo (prefer single), else try to beat with minimal higher combo.

    // Build frequency map for quick lookup
    Map<int, List<CardModel>> byRank = {};
    for (var c in ai.hand) {
      byRank.putIfAbsent(c.rank, () => []).add(c);
    }

    List<CardModel>? choosePlay() {
      if (lastPlayed == null) {
        // Play lowest single
        return [ai.hand.first];
      }
      final prevCombo = analyseCombo(lastPlayed!);

      // singles
      if (prevCombo.type == ComboType.single) {
        for (var card in ai.hand) {
          if (card.rank > prevCombo.mainRank) return [card];
        }
      }
      // pair
      if (prevCombo.type == ComboType.pair) {
        for (var entry in byRank.entries) {
          if (entry.value.length >= 2 && entry.key > prevCombo.mainRank) {
            return entry.value.sublist(0, 2);
          }
        }
      }
      // triple
      if (prevCombo.type == ComboType.triple) {
        for (var entry in byRank.entries) {
          if (entry.value.length >= 3 && entry.key > prevCombo.mainRank) {
            return entry.value.sublist(0, 3);
          }
        }
      }

      // Try bomb
      for (var entry in byRank.entries) {
        if (entry.value.length == 4) return entry.value; // bomb
      }
      // king bomb
      if (byRank.containsKey(16) && byRank.containsKey(17)) {
        return [byRank[16]!.first, byRank[17]!.first];
      }
      return null;
    }

    final play = choosePlay();
    if (play == null) {
      pass(ai);
      return;
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