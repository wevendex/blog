import '../models/card.dart';

enum ComboType {
  single,
  pair,
  triple,
  tripleWithSingle,
  tripleWithPair,
  straight,
  consecutivePairs,
  plane,
  bomb,
  kingBomb,
  invalid,
}

class Combo {
  final ComboType type;
  final List<CardModel> cards;
  final int mainRank; // used to compare combos of same type

  const Combo(this.type, this.cards, this.mainRank);

  bool get isValid => type != ComboType.invalid;
}

// Analyse the given cards into a Combo. Order of cards irrelevant.
Combo analyseCombo(List<CardModel> input) {
  if (input.isEmpty) return const Combo(ComboType.invalid, [], 0);
  // Sort by rank ascending.
  final cards = List<CardModel>.from(input)..sort();
  final ranks = cards.map((e) => e.rank).toList();
  final len = cards.length;

  // Helper
  bool allSameRank() => ranks.every((r) => r == ranks.first);
  Map<int, int> freq() {
    final m = <int, int>{};
    for (var r in ranks) {
      m[r] = (m[r] ?? 0) + 1;
    }
    return m;
  }

  // King Bomb
  if (len == 2 && ranks.contains(16) && ranks.contains(17)) {
    return Combo(ComboType.kingBomb, cards, 17);
  }

  final f = freq();

  // Bomb
  if (len == 4 && f.values.any((c) => c == 4)) {
    return Combo(ComboType.bomb, cards, ranks.first);
  }

  // Singles / Pair / Triple
  if (len == 1) {
    return Combo(ComboType.single, cards, ranks.first);
  }
  if (len == 2 && allSameRank()) {
    return Combo(ComboType.pair, cards, ranks.first);
  }
  if (len == 3 && allSameRank()) {
    return Combo(ComboType.triple, cards, ranks.first);
  }

  // Triple with single
  if (len == 4 && f.values.contains(3)) {
    final tripleRank = f.entries.firstWhere((e) => e.value == 3).key;
    return Combo(ComboType.tripleWithSingle, cards, tripleRank);
  }

  // Triple with pair
  if (len == 5 && f.values.contains(3) && f.values.contains(2)) {
    final tripleRank = f.entries.firstWhere((e) => e.value == 3).key;
    return Combo(ComboType.tripleWithPair, cards, tripleRank);
  }

  // Straight: length >=5 consecutive, ranks < 15 (no 2 or jokers)
  bool isStraight() {
    if (len < 5) return false;
    if (ranks.any((r) => r >= 15)) return false; // 2 and jokers not allowed
    for (int i = 1; i < ranks.length; i++) {
      if (ranks[i] != ranks[i - 1] + 1) return false;
    }
    return true;
  }

  if (isStraight()) {
    return Combo(ComboType.straight, cards, ranks.last);
  }

  // Consecutive pairs
  bool isConsecutivePairs() {
    if (len < 6 || len % 2 != 0) return false;
    if (ranks.any((r) => r >= 15)) return false;
    for (int i = 0; i < ranks.length; i += 2) {
      if (ranks[i] != ranks[i + 1]) return false; // ensure pair
      if (i >= 2 && ranks[i] != ranks[i - 2] + 1) return false; // consecutive
    }
    return true;
  }

  if (isConsecutivePairs()) {
    return Combo(ComboType.consecutivePairs, cards, ranks.last);
  }

  // Plane (consecutive triples) - wings not enforced here
  bool isPlane() {
    if (len % 3 != 0 || len < 6) return false;
    if (ranks.any((r) => r >= 15)) return false;
    for (int i = 0; i < ranks.length; i += 3) {
      if (!(ranks[i] == ranks[i + 1] && ranks[i] == ranks[i + 2])) return false;
      if (i >= 3 && ranks[i] != ranks[i - 3] + 1) return false;
    }
    return true;
  }

  if (isPlane()) {
    return Combo(ComboType.plane, cards, ranks.last);
  }

  return const Combo(ComboType.invalid, [], 0);
}

bool canBeat(Combo play, Combo prev) {
  if (!play.isValid) return false;
  if (!prev.isValid) return true; // starting trick

  // King bomb beats everything
  if (play.type == ComboType.kingBomb) return true;
  // Bomb beats anything except king bomb or bigger bomb
  if (play.type == ComboType.bomb && prev.type != ComboType.bomb && prev.type != ComboType.kingBomb) {
    return true;
  }
  // Same type comparison
  if (play.type == prev.type && play.cards.length == prev.cards.length) {
    return play.mainRank > prev.mainRank;
  }
  // Bomb vs bomb
  if (play.type == ComboType.bomb && prev.type == ComboType.bomb) {
    return play.mainRank > prev.mainRank;
  }
  return false;
}