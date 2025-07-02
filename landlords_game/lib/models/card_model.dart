import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'card_model.g.dart';

// 花色枚举
enum CardSuit {
  @JsonValue('spades')
  spades,    // 黑桃♠
  @JsonValue('hearts')
  hearts,    // 红桃♥
  @JsonValue('diamonds')
  diamonds,  // 方块♦
  @JsonValue('clubs')
  clubs,     // 梅花♣
  @JsonValue('joker')
  joker,     // 大小王
}

// 卡牌类型枚举
enum CardType {
  @JsonValue('normal')
  normal,    // 普通牌
  @JsonValue('joker_small')
  jokerSmall, // 小王
  @JsonValue('joker_big')
  jokerBig,   // 大王
}

@JsonSerializable()
class CardModel extends Equatable {
  final CardSuit suit;        // 花色
  final int rank;             // 点数 (3-15, 其中14=A, 15=2, 16=小王, 17=大王)
  final CardType type;        // 卡牌类型
  final String id;            // 唯一标识
  final bool isSelected;      // 是否被选中
  final bool isPlayable;      // 是否可打出

  const CardModel({
    required this.suit,
    required this.rank,
    required this.type,
    required this.id,
    this.isSelected = false,
    this.isPlayable = true,
  });

  // 创建普通扑克牌
  factory CardModel.normal({
    required CardSuit suit,
    required int rank,
    bool isSelected = false,
    bool isPlayable = true,
  }) {
    return CardModel(
      suit: suit,
      rank: rank,
      type: CardType.normal,
      id: '${suit.name}_$rank',
      isSelected: isSelected,
      isPlayable: isPlayable,
    );
  }

  // 创建小王
  factory CardModel.smallJoker({
    bool isSelected = false,
    bool isPlayable = true,
  }) {
    return CardModel(
      suit: CardSuit.joker,
      rank: 16,
      type: CardType.jokerSmall,
      id: 'joker_small',
      isSelected: isSelected,
      isPlayable: isPlayable,
    );
  }

  // 创建大王
  factory CardModel.bigJoker({
    bool isSelected = false,
    bool isPlayable = true,
  }) {
    return CardModel(
      suit: CardSuit.joker,
      rank: 17,
      type: CardType.jokerBig,
      id: 'joker_big',
      isSelected: isSelected,
      isPlayable: isPlayable,
    );
  }

  // 获取卡牌显示名称
  String get displayName {
    switch (type) {
      case CardType.jokerSmall:
        return '小王';
      case CardType.jokerBig:
        return '大王';
      case CardType.normal:
        String rankName;
        switch (rank) {
          case 11:
            rankName = 'J';
            break;
          case 12:
            rankName = 'Q';
            break;
          case 13:
            rankName = 'K';
            break;
          case 14:
            rankName = 'A';
            break;
          case 15:
            rankName = '2';
            break;
          default:
            rankName = rank.toString();
        }
        return '$rankName${suitSymbol}';
    }
  }

  // 获取花色符号
  String get suitSymbol {
    switch (suit) {
      case CardSuit.spades:
        return '♠';
      case CardSuit.hearts:
        return '♥';
      case CardSuit.diamonds:
        return '♦';
      case CardSuit.clubs:
        return '♣';
      case CardSuit.joker:
        return '';
    }
  }

  // 获取花色颜色
  bool get isRed {
    return suit == CardSuit.hearts || suit == CardSuit.diamonds;
  }

  // 获取卡牌图片资源路径
  String get imagePath {
    switch (type) {
      case CardType.jokerSmall:
        return 'assets/images/cards/joker_small.png';
      case CardType.jokerBig:
        return 'assets/images/cards/joker_big.png';
      case CardType.normal:
        return 'assets/images/cards/${suit.name}_$rank.png';
    }
  }

  // 获取卡牌权重（用于比较大小）
  int get weight {
    switch (type) {
      case CardType.normal:
        // 3,4,5,6,7,8,9,10,J,Q,K,A,2 对应权重 3-15
        return rank;
      case CardType.jokerSmall:
        return 16;
      case CardType.jokerBig:
        return 17;
    }
  }

  // 是否为王牌
  bool get isJoker => type == CardType.jokerSmall || type == CardType.jokerBig;

  // 复制并修改属性
  CardModel copyWith({
    CardSuit? suit,
    int? rank,
    CardType? type,
    String? id,
    bool? isSelected,
    bool? isPlayable,
  }) {
    return CardModel(
      suit: suit ?? this.suit,
      rank: rank ?? this.rank,
      type: type ?? this.type,
      id: id ?? this.id,
      isSelected: isSelected ?? this.isSelected,
      isPlayable: isPlayable ?? this.isPlayable,
    );
  }

  // JSON序列化
  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);
  Map<String, dynamic> toJson() => _$CardModelToJson(this);

  @override
  List<Object?> get props => [suit, rank, type, id, isSelected, isPlayable];

  @override
  String toString() {
    return 'CardModel(${displayName}, selected: $isSelected, playable: $isPlayable)';
  }
}

// 卡牌比较器
class CardComparator {
  // 比较两张牌的大小（返回 -1, 0, 1）
  static int compare(CardModel a, CardModel b) {
    return a.weight.compareTo(b.weight);
  }

  // 按花色和点数排序
  static int compareByRankAndSuit(CardModel a, CardModel b) {
    // 先按点数排序
    final rankComparison = a.rank.compareTo(b.rank);
    if (rankComparison != 0) return rankComparison;
    
    // 点数相同，按花色排序
    return a.suit.index.compareTo(b.suit.index);
  }
}

// 扑克牌工厂类
class CardFactory {
  // 创建完整的54张牌组
  static List<CardModel> createFullDeck() {
    final List<CardModel> cards = [];
    
    // 创建普通牌 3-A，四种花色各13张，共52张
    for (final suit in [CardSuit.spades, CardSuit.hearts, CardSuit.diamonds, CardSuit.clubs]) {
      for (int rank = 3; rank <= 15; rank++) {
        cards.add(CardModel.normal(suit: suit, rank: rank));
      }
    }
    
    // 添加大小王
    cards.add(CardModel.smallJoker());
    cards.add(CardModel.bigJoker());
    
    return cards;
  }

  // 洗牌
  static List<CardModel> shuffleDeck(List<CardModel> cards) {
    final shuffled = List<CardModel>.from(cards);
    shuffled.shuffle();
    return shuffled;
  }

  // 从JSON创建卡牌列表
  static List<CardModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CardModel.fromJson(json)).toList();
  }

  // 转换为JSON列表
  static List<Map<String, dynamic>> toJsonList(List<CardModel> cards) {
    return cards.map((card) => card.toJson()).toList();
  }
}