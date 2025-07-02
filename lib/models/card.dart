enum Suit { spade, heart, club, diamond, joker }

class CardModel implements Comparable<CardModel> {
  final Suit suit;
  final int rank; // 3-15 (3..10: 3-10, 11:J,12:Q,13:K,14:A,15:2, 16:Small Joker, 17:Big Joker)

  const CardModel({required this.suit, required this.rank});

  bool get isJoker => suit == Suit.joker;

  @override
  int compareTo(CardModel other) => rank.compareTo(other.rank);

  @override
  String toString() {
    if (isJoker) {
      return rank == 16 ? 'SJ' : 'BJ';
    }
    const rankMap = {
      3: '3',
      4: '4',
      5: '5',
      6: '6',
      7: '7',
      8: '8',
      9: '9',
      10: '10',
      11: 'J',
      12: 'Q',
      13: 'K',
      14: 'A',
      15: '2',
    };
    const suitMap = {
      Suit.spade: '♠',
      Suit.heart: '♥',
      Suit.club: '♣',
      Suit.diamond: '♦',
    };

    return '${suitMap[suit]}${rankMap[rank] ?? rank}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel && runtimeType == other.runtimeType && suit == other.suit && rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
}