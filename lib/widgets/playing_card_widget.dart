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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isSelected ? Colors.blue : Colors.black, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          card.toString(),
          style: TextStyle(
            fontSize: 18,
            color: card.suit == Suit.heart || card.suit == Suit.diamond ? Colors.red : Colors.black,
          ),
        ),
      ),
    );
  }
}