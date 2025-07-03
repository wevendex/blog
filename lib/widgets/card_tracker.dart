import 'package:flutter/material.dart';
import '../models/card.dart';

class CardTracker extends StatelessWidget {
  final List<CardModel> playedCards;
  final bool isVisible;

  const CardTracker({
    Key? key,
    required this.playedCards,
    this.isVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final cardCounts = _calculateCardCounts();

    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '记牌器',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 牌型统计网格
          _buildCardGrid(cardCounts),
        ],
      ),
    );
  }

  Widget _buildCardGrid(Map<String, int> cardCounts) {
    // 定义所有牌型（斗地主标准54张牌）
    final cardTypes = [
      '3', '4', '5', '6', '7', '8', '9', '10', 
      'J', 'Q', 'K', 'A', '2', '小王', '大王'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.1,
      ),
      itemCount: cardTypes.length,
      itemBuilder: (context, index) {
        final cardType = cardTypes[index];
        final remainingCount = cardCounts[cardType] ?? 0;
        
        return _buildCardCountItem(cardType, remainingCount);
      },
    );
  }

  Widget _buildCardCountItem(String cardType, int remainingCount) {
    // 根据剩余数量确定颜色
    Color getCountColor() {
      if (remainingCount == 0) return Colors.red;
      if (remainingCount == 1) return Colors.orange;
      if (remainingCount == 2) return Colors.yellow;
      return Colors.green;
    }

    // 根据剩余数量确定透明度
    double getOpacity() {
      if (remainingCount == 0) return 0.3;
      return 1.0;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: getCountColor().withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: getOpacity(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 牌面值
            Text(
              cardType,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            // 剩余数量
            Text(
              remainingCount.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: getCountColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _calculateCardCounts() {
    // 初始化标准牌组数量（除了大小王，每种牌4张）
    final Map<String, int> initialCounts = {
      '3': 4, '4': 4, '5': 4, '6': 4, '7': 4, '8': 4, '9': 4, '10': 4,
      'J': 4, 'Q': 4, 'K': 4, 'A': 4, '2': 4,
      '小王': 1, '大王': 1,
    };

    // 计算已出的牌
    final Map<String, int> playedCounts = {};
    for (var card in playedCards) {
      String cardValue = _getCardDisplayValue(card);
      playedCounts[cardValue] = (playedCounts[cardValue] ?? 0) + 1;
    }

    // 计算剩余数量
    final Map<String, int> remainingCounts = {};
    initialCounts.forEach((cardType, initialCount) {
      final playedCount = playedCounts[cardType] ?? 0;
      remainingCounts[cardType] = initialCount - playedCount;
    });

    return remainingCounts;
  }

  String _getCardDisplayValue(CardModel card) {
    // 处理特殊牌面值
    switch (card.value) {
      case 11:
        return 'J';
      case 12:
        return 'Q';
      case 13:
        return 'K';
      case 14:
        return 'A';
      case 15:
        return '2';
      case 16:
        return '小王';
      case 17:
        return '大王';
      default:
        return card.value.toString();
    }
  }
}

// 记牌器管理器
class CardTrackerManager {
  static final List<CardModel> _allPlayedCards = [];

  // 添加已出的牌
  static void addPlayedCards(List<CardModel> cards) {
    _allPlayedCards.addAll(cards);
  }

  // 获取所有已出的牌
  static List<CardModel> get allPlayedCards => List.unmodifiable(_allPlayedCards);

  // 清空记录（新游戏开始时调用）
  static void reset() {
    _allPlayedCards.clear();
  }

  // 获取指定类型牌的剩余数量
  static int getRemainingCount(int cardValue) {
    final playedCount = _allPlayedCards
        .where((card) => card.value == cardValue)
        .length;
    
    // 确定初始数量
    int initialCount;
    if (cardValue == 16 || cardValue == 17) { // 大小王
      initialCount = 1;
    } else {
      initialCount = 4;
    }
    
    return initialCount - playedCount;
  }

  // 检查是否还有指定类型的牌
  static bool hasRemainingCards(int cardValue) {
    return getRemainingCount(cardValue) > 0;
  }
}