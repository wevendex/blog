import 'package:flutter/material.dart';
import '../models/card.dart';

class PlayingCardWidget extends StatelessWidget {
  final CardModel card;
  final bool isSelected;
  final VoidCallback? onTap;
  const PlayingCardWidget({Key? key, required this.card, this.isSelected = false, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          height: 100,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: isSelected ? Colors.blue : Colors.black, width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _rankSuitText(card, top: true),
              RotatedBox(
                quarterTurns: 2,
                child: _rankSuitText(card, top: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rankSuitText(CardModel card, {required bool top}) {
    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    String suitSymbol;
    switch (card.suit) {
      case Suit.spade:
        suitSymbol = '♠';
        break;
      case Suit.heart:
        suitSymbol = '♥';
        break;
      case Suit.club:
        suitSymbol = '♣';
        break;
      case Suit.diamond:
        suitSymbol = '♦';
        break;
      case Suit.joker:
        suitSymbol = card.rank == 16 ? 'SJ' : 'BJ';
        break;
    }

    final rankText = card.rank <= 10 ? card.rank.toString() : {
      11: 'J',
      12: 'Q',
      13: 'K',
      14: 'A',
      15: '2',
      16: 'SJ',
      17: 'BJ',
    }[card.rank] ?? '';

    final first = top ? rankText : suitSymbol;
    final second = top ? suitSymbol : rankText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(first, style: TextStyle(fontSize: 12, color: color)),
        Text(second, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}