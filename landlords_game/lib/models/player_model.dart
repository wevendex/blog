import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'card_model.dart';

part 'player_model.g.dart';

// 玩家角色枚举
enum PlayerRole {
  @JsonValue('farmer')
  farmer,     // 农民
  @JsonValue('landlord')
  landlord,   // 地主
  @JsonValue('unknown')
  unknown,    // 未知/未分配
}

// 玩家状态枚举
enum PlayerStatus {
  @JsonValue('waiting')
  waiting,        // 等待中
  @JsonValue('ready')
  ready,          // 准备就绪
  @JsonValue('playing')
  playing,        // 游戏中
  @JsonValue('thinking')
  thinking,       // 思考中
  @JsonValue('offline')
  offline,        // 离线
  @JsonValue('finished')
  finished,       // 已完成
}

// 玩家等级信息
@JsonSerializable()
class PlayerLevel extends Equatable {
  final int level;          // 等级
  final int experience;     // 当前经验值
  final int expToNext;      // 到下一级所需经验
  final String title;       // 称号

  const PlayerLevel({
    required this.level,
    required this.experience,
    required this.expToNext,
    required this.title,
  });

  factory PlayerLevel.fromJson(Map<String, dynamic> json) => _$PlayerLevelFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerLevelToJson(this);

  @override
  List<Object?> get props => [level, experience, expToNext, title];
}

// 玩家统计信息
@JsonSerializable()
class PlayerStats extends Equatable {
  final int totalGames;     // 总游戏数
  final int winGames;       // 胜利数
  final int loseGames;      // 失败数
  final double winRate;     // 胜率
  final int bestStreak;     // 最佳连胜
  final int currentStreak;  // 当前连胜
  final int totalCoins;     // 总金币

  const PlayerStats({
    required this.totalGames,
    required this.winGames,
    required this.loseGames,
    required this.winRate,
    required this.bestStreak,
    required this.currentStreak,
    required this.totalCoins,
  });

  factory PlayerStats.initial() {
    return const PlayerStats(
      totalGames: 0,
      winGames: 0,
      loseGames: 0,
      winRate: 0.0,
      bestStreak: 0,
      currentStreak: 0,
      totalCoins: 1000,
    );
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) => _$PlayerStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerStatsToJson(this);

  @override
  List<Object?> get props => [totalGames, winGames, loseGames, winRate, bestStreak, currentStreak, totalCoins];
}

@JsonSerializable()
class PlayerModel extends Equatable {
  final String id;              // 唯一标识
  final String nickname;        // 昵称
  final String avatar;          // 头像URL
  final PlayerRole role;        // 角色
  final PlayerStatus status;    // 状态
  final PlayerLevel level;      // 等级信息
  final PlayerStats stats;      // 统计信息
  final List<CardModel> cards;  // 手牌
  final bool isBot;             // 是否为机器人
  final bool isOnline;          // 是否在线
  final DateTime lastActiveTime; // 最后活跃时间
  final int seatIndex;          // 座位索引 (0-2)
  final bool isReady;           // 是否准备
  final bool hasCalledLandlord; // 是否已叫地主
  final bool hasPassed;         // 是否已过牌

  const PlayerModel({
    required this.id,
    required this.nickname,
    required this.avatar,
    this.role = PlayerRole.unknown,
    this.status = PlayerStatus.waiting,
    required this.level,
    required this.stats,
    this.cards = const [],
    this.isBot = false,
    this.isOnline = true,
    required this.lastActiveTime,
    this.seatIndex = -1,
    this.isReady = false,
    this.hasCalledLandlord = false,
    this.hasPassed = false,
  });

  // 创建机器人玩家
  factory PlayerModel.bot({
    required String id,
    required String nickname,
    required int seatIndex,
  }) {
    return PlayerModel(
      id: id,
      nickname: nickname,
      avatar: 'assets/images/avatars/bot_${(seatIndex % 6) + 1}.png',
      level: PlayerLevel(
        level: 10 + (seatIndex * 5),
        experience: 1000,
        expToNext: 500,
        title: '电脑对手',
      ),
      stats: PlayerStats.initial(),
      isBot: true,
      lastActiveTime: DateTime.now(),
      seatIndex: seatIndex,
    );
  }

  // 创建初始玩家
  factory PlayerModel.initial({
    required String id,
    required String nickname,
    String? avatar,
  }) {
    return PlayerModel(
      id: id,
      nickname: nickname,
      avatar: avatar ?? 'assets/images/avatars/default.png',
      level: const PlayerLevel(
        level: 1,
        experience: 0,
        expToNext: 100,
        title: '新手',
      ),
      stats: PlayerStats.initial(),
      lastActiveTime: DateTime.now(),
    );
  }

  // 获取玩家称号
  String get titleName {
    if (level.level < 10) return '新手';
    if (level.level < 20) return '初级玩家';
    if (level.level < 30) return '中级玩家';
    if (level.level < 50) return '高级玩家';
    if (level.level < 80) return '专家';
    if (level.level < 100) return '大师';
    return '传奇';
  }

  // 获取角色显示名称
  String get roleDisplayName {
    switch (role) {
      case PlayerRole.landlord:
        return '地主';
      case PlayerRole.farmer:
        return '农民';
      case PlayerRole.unknown:
        return '';
    }
  }

  // 获取状态显示名称
  String get statusDisplayName {
    switch (status) {
      case PlayerStatus.waiting:
        return '等待中';
      case PlayerStatus.ready:
        return '已准备';
      case PlayerStatus.playing:
        return '游戏中';
      case PlayerStatus.thinking:
        return '思考中';
      case PlayerStatus.offline:
        return '离线';
      case PlayerStatus.finished:
        return '已完成';
    }
  }

  // 是否是地主
  bool get isLandlord => role == PlayerRole.landlord;

  // 是否是农民
  bool get isFarmer => role == PlayerRole.farmer;

  // 获取手牌数量
  int get cardCount => cards.length;

  // 是否出完牌
  bool get hasFinished => cards.isEmpty;

  // 复制并修改属性
  PlayerModel copyWith({
    String? id,
    String? nickname,
    String? avatar,
    PlayerRole? role,
    PlayerStatus? status,
    PlayerLevel? level,
    PlayerStats? stats,
    List<CardModel>? cards,
    bool? isBot,
    bool? isOnline,
    DateTime? lastActiveTime,
    int? seatIndex,
    bool? isReady,
    bool? hasCalledLandlord,
    bool? hasPassed,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      status: status ?? this.status,
      level: level ?? this.level,
      stats: stats ?? this.stats,
      cards: cards ?? this.cards,
      isBot: isBot ?? this.isBot,
      isOnline: isOnline ?? this.isOnline,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      seatIndex: seatIndex ?? this.seatIndex,
      isReady: isReady ?? this.isReady,
      hasCalledLandlord: hasCalledLandlord ?? this.hasCalledLandlord,
      hasPassed: hasPassed ?? this.hasPassed,
    );
  }

  // 添加卡牌
  PlayerModel addCards(List<CardModel> newCards) {
    final allCards = [...cards, ...newCards];
    // 按权重排序
    allCards.sort((a, b) => a.weight.compareTo(b.weight));
    return copyWith(cards: allCards);
  }

  // 移除卡牌
  PlayerModel removeCards(List<CardModel> cardsToRemove) {
    final remainingCards = cards.where((card) {
      return !cardsToRemove.any((removeCard) => removeCard.id == card.id);
    }).toList();
    return copyWith(cards: remainingCards);
  }

  // 更新状态
  PlayerModel updateStatus(PlayerStatus newStatus) {
    return copyWith(
      status: newStatus,
      lastActiveTime: DateTime.now(),
    );
  }

  // 设置为地主
  PlayerModel setAsLandlord() {
    return copyWith(
      role: PlayerRole.landlord,
      hasCalledLandlord: true,
    );
  }

  // 设置为农民
  PlayerModel setAsFarmer() {
    return copyWith(role: PlayerRole.farmer);
  }

  // JSON序列化
  factory PlayerModel.fromJson(Map<String, dynamic> json) => _$PlayerModelFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        nickname,
        avatar,
        role,
        status,
        level,
        stats,
        cards,
        isBot,
        isOnline,
        lastActiveTime,
        seatIndex,
        isReady,
        hasCalledLandlord,
        hasPassed,
      ];

  @override
  String toString() {
    return 'PlayerModel(id: $id, nickname: $nickname, role: $role, cards: ${cards.length})';
  }
}