import 'package:flutter/material.dart';
import '../models/card.dart';

class PlayingCardWidget extends StatelessWidget {
  final CardModel card;
  final bool isSelected;
  final VoidCallback? onTap;
  const PlayingCardWidget({Key? key, required this.card, this.isSelected = false, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetName = _assetNameForCard(card);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: assetName != null
            ? Image.asset(assetName, height: 80, fit: BoxFit.fitHeight)
            : Container(
                padding: const EdgeInsets.all(4),
                color: Colors.white,
                child: Text(
                  card.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: card.suit == Suit.heart || card.suit == Suit.diamond ? Colors.red : Colors.black,
                  ),
                ),
              ),
      ),
    );
  }

  String? _assetNameForCard(CardModel card) {
    if (card.isJoker) {
      return 'assets/cards/${card.rank == 16 ? 'sjoker' : 'bjoker'}.png';
    }
    final rankMap = {
      3: '3',
      4: '4',
      5: '5',
      6: '6',
      7: '7',
      8: '8',
      9: '9',
      10: '10',
      11: 'j',
      12: 'q',
      13: 'k',
      14: 'a',
      15: '2',
    };
    final suitMap = {
      Suit.spade: 'spade',
      Suit.heart: 'heart',
      Suit.club: 'club',
      Suit.diamond: 'diamond',
    };
    final rankStr = rankMap[card.rank];
    final suitStr = suitMap[card.suit];
    if (rankStr == null || suitStr == null) return null;
    return 'assets/cards/${rankStr}_of_${suitStr}.png';
  }
}