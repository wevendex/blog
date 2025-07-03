import 'package:flutter/material.dart';
import '../models/card.dart';

class PlayingCardWidget extends StatefulWidget {
  final CardModel card;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isPlayAnimation;
  final bool isDealAnimation;
  final Duration animationDelay;
  
  const PlayingCardWidget({
    Key? key, 
    required this.card, 
    this.isSelected = false, 
    this.onTap,
    this.isPlayAnimation = false,
    this.isDealAnimation = false,
    this.animationDelay = Duration.zero,
  }) : super(key: key);

  @override
  State<PlayingCardWidget> createState() => _PlayingCardWidgetState();
}

class _PlayingCardWidgetState extends State<PlayingCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _dealController;
  
  late Animation<double> _moveAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _dealSlideAnimation;
  late Animation<double> _dealRotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _dealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _moveAnimation = Tween<double>(
      begin: 0.0,
      end: -120.0,
    ).animate(CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));
    
    _dealSlideAnimation = Tween<double>(
      begin: -200.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _dealController,
      curve: Curves.easeOutBack,
    ));
    
    _dealRotateAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _dealController,
      curve: Curves.easeOutBack,
    ));

    // 处理发牌动画
    if (widget.isDealAnimation) {
      Future.delayed(widget.animationDelay, () {
        if (mounted) {
          _dealController.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(PlayingCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 处理选择动画
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _scaleController.forward();
      } else {
        _scaleController.reverse();
      }
    }
    
    // 处理出牌动画
    if (widget.isPlayAnimation && !oldWidget.isPlayAnimation) {
      _playCardAnimation();
    }
  }

  Future<void> _playCardAnimation() async {
    await _moveController.forward();
    await _rotateController.forward();
    // 动画完成后重置
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _moveController.reset();
        _rotateController.reset();
      }
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _dealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _moveAnimation,
          _scaleAnimation,
          _rotateAnimation,
          _dealSlideAnimation,
          _dealRotateAnimation,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _dealSlideAnimation.value,
              _moveAnimation.value + (widget.isSelected ? -15 : 0)
            ),
            child: Transform.rotate(
              angle: _rotateAnimation.value + _dealRotateAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  height: 100,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: widget.isSelected ? Colors.amber : Colors.black87, 
                      width: widget.isSelected ? 3 : 1.5
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isSelected 
                            ? Colors.amber.withOpacity(0.4)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: widget.isSelected ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _rankSuitText(widget.card, top: true),
                      // 中央花色显示
                      _buildCenterSuit(widget.card),
                      RotatedBox(
                        quarterTurns: 2,
                        child: _rankSuitText(widget.card, top: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCenterSuit(CardModel card) {
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
        suitSymbol = card.rank == 16 ? '🃏' : '🤹';
        break;
    }

    return Text(
      suitSymbol,
      style: TextStyle(
        fontSize: 24,
        color: color,
        fontWeight: FontWeight.bold,
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