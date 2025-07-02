import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'card_model.dart';
import 'player_model.dart';

part 'game_model.g.dart';

// 游戏状态枚举
enum GameState {
  @JsonValue('waiting')
  waiting,        // 等待玩家
  @JsonValue('ready')
  ready,          // 准备开始
  @JsonValue('dealing')
  dealing,        // 发牌中
  @JsonValue('calling')
  calling,        // 叫地主中
  @JsonValue('playing')
  playing,        // 游戏进行中
  @JsonValue('finished')
  finished,       // 游戏结束
  @JsonValue('paused')
  paused,         // 暂停
}

// 游戏类型枚举
enum GameType {
  @JsonValue('classic')
  classic,        // 经典模式
  @JsonValue('happy')
  happy,          // 欢乐模式
  @JsonValue('tournament')
  tournament,     // 锦标赛
  @JsonValue('quick')
  quick,          // 快速游戏
}

// 游戏难度枚举
enum GameDifficulty {
  @JsonValue('easy')
  easy,           // 简单
  @JsonValue('normal')
  normal,         // 普通
  @JsonValue('hard')
  hard,           // 困难
}

// 出牌类型枚举
enum PlayType {
  @JsonValue('single')
  single,         // 单张
  @JsonValue('pair')
  pair,           // 对子
  @JsonValue('triple')
  triple,         // 三张
  @JsonValue('triple_with_single')
  tripleWithSingle, // 三带一
  @JsonValue('triple_with_pair')
  tripleWithPair,   // 三带二
  @JsonValue('straight')
  straight,       // 顺子
  @JsonValue('pair_straight')
  pairStraight,   // 连对
  @JsonValue('plane')
  plane,          // 飞机
  @JsonValue('plane_with_single')
  planeWithSingle, // 飞机带单
  @JsonValue('plane_with_pair')
  planeWithPair,   // 飞机带对
  @JsonValue('bomb')
  bomb,           // 炸弹
  @JsonValue('rocket')
  rocket,         // 火箭
  @JsonValue('four_with_two')
  fourWithTwo,    // 四带二
  @JsonValue('invalid')
  invalid,        // 无效
}

// 游戏配置
@JsonSerializable()
class GameConfig extends Equatable {
  final GameType type;              // 游戏类型
  final GameDifficulty difficulty;  // 难度
  final int baseScore;              // 底分
  final int multiplier;             // 倍数
  final bool allowRocket;           // 是否允许火箭
  final bool allowBomb;             // 是否允许炸弹
  final int maxPlayers;             // 最大玩家数
  final int timeLimit;              // 操作时间限制（秒）

  const GameConfig({
    this.type = GameType.classic,
    this.difficulty = GameDifficulty.normal,
    this.baseScore = 100,
    this.multiplier = 1,
    this.allowRocket = true,
    this.allowBomb = true,
    this.maxPlayers = 3,
    this.timeLimit = 30,
  });

  factory GameConfig.fromJson(Map<String, dynamic> json) => _$GameConfigFromJson(json);
  Map<String, dynamic> toJson() => _$GameConfigToJson(this);

  @override
  List<Object?> get props => [type, difficulty, baseScore, multiplier, allowRocket, allowBomb, maxPlayers, timeLimit];
}

// 出牌记录
@JsonSerializable()
class PlayRecord extends Equatable {
  final String playerId;            // 玩家ID
  final List<CardModel> cards;      // 出的牌
  final PlayType playType;          // 出牌类型
  final DateTime timestamp;         // 时间戳
  final bool isPassed;              // 是否过牌

  const PlayRecord({
    required this.playerId,
    required this.cards,
    required this.playType,
    required this.timestamp,
    this.isPassed = false,
  });

  factory PlayRecord.pass(String playerId) {
    return PlayRecord(
      playerId: playerId,
      cards: const [],
      playType: PlayType.invalid,
      timestamp: DateTime.now(),
      isPassed: true,
    );
  }

  factory PlayRecord.fromJson(Map<String, dynamic> json) => _$PlayRecordFromJson(json);
  Map<String, dynamic> toJson() => _$PlayRecordToJson(this);

  @override
  List<Object?> get props => [playerId, cards, playType, timestamp, isPassed];
}

// 游戏结果
@JsonSerializable()
class GameResult extends Equatable {
  final String winnerId;            // 获胜者ID
  final List<String> winnerTeam;    // 获胜队伍
  final Map<String, int> scores;    // 各玩家得分
  final Map<String, int> coins;     // 各玩家金币变化
  final int duration;               // 游戏时长（秒）
  final DateTime finishTime;        // 结束时间

  const GameResult({
    required this.winnerId,
    required this.winnerTeam,
    required this.scores,
    required this.coins,
    required this.duration,
    required this.finishTime,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) => _$GameResultFromJson(json);
  Map<String, dynamic> toJson() => _$GameResultToJson(this);

  @override
  List<Object?> get props => [winnerId, winnerTeam, scores, coins, duration, finishTime];
}

@JsonSerializable()
class GameModel extends Equatable {
  final String id;                      // 游戏ID
  final String roomId;                  // 房间ID
  final GameState state;                // 游戏状态
  final GameConfig config;              // 游戏配置
  final List<PlayerModel> players;      // 玩家列表
  final List<CardModel> bottomCards;    // 底牌
  final String? currentPlayerId;        // 当前操作玩家ID
  final String? landlordId;             // 地主ID
  final List<PlayRecord> playHistory;   // 出牌历史
  final PlayRecord? lastPlay;           // 最后一次出牌
  final int currentMultiplier;          // 当前倍数
  final DateTime startTime;             // 开始时间
  final DateTime? endTime;              // 结束时间
  final GameResult? result;             // 游戏结果
  final int round;                      // 回合数
  final Map<String, bool> callingStatus; // 叫地主状态

  const GameModel({
    required this.id,
    required this.roomId,
    required this.state,
    required this.config,
    required this.players,
    this.bottomCards = const [],
    this.currentPlayerId,
    this.landlordId,
    this.playHistory = const [],
    this.lastPlay,
    this.currentMultiplier = 1,
    required this.startTime,
    this.endTime,
    this.result,
    this.round = 0,
    this.callingStatus = const {},
  });

  // 创建新游戏
  factory GameModel.create({
    required String id,
    required String roomId,
    required List<PlayerModel> players,
    GameConfig? config,
  }) {
    return GameModel(
      id: id,
      roomId: roomId,
      state: GameState.waiting,
      config: config ?? const GameConfig(),
      players: players,
      startTime: DateTime.now(),
    );
  }

  // 获取当前玩家
  PlayerModel? get currentPlayer {
    if (currentPlayerId == null) return null;
    return players.where((p) => p.id == currentPlayerId).firstOrNull;
  }

  // 获取地主
  PlayerModel? get landlord {
    if (landlordId == null) return null;
    return players.where((p) => p.id == landlordId).firstOrNull;
  }

  // 获取农民
  List<PlayerModel> get farmers {
    return players.where((p) => p.role == PlayerRole.farmer).toList();
  }

  // 获取在线玩家
  List<PlayerModel> get onlinePlayers {
    return players.where((p) => p.isOnline).toList();
  }

  // 是否所有玩家准备就绪
  bool get allPlayersReady {
    return players.every((p) => p.isReady || p.isBot);
  }

  // 是否游戏中
  bool get isPlaying {
    return state == GameState.playing;
  }

  // 是否游戏结束
  bool get isFinished {
    return state == GameState.finished;
  }

  // 是否在叫地主阶段
  bool get isCalling {
    return state == GameState.calling;
  }

  // 获取下一个玩家
  PlayerModel? getNextPlayer(String currentId) {
    final currentIndex = players.indexWhere((p) => p.id == currentId);
    if (currentIndex == -1) return null;
    
    final nextIndex = (currentIndex + 1) % players.length;
    return players[nextIndex];
  }

  // 复制并修改属性
  GameModel copyWith({
    String? id,
    String? roomId,
    GameState? state,
    GameConfig? config,
    List<PlayerModel>? players,
    List<CardModel>? bottomCards,
    String? currentPlayerId,
    String? landlordId,
    List<PlayRecord>? playHistory,
    PlayRecord? lastPlay,
    int? currentMultiplier,
    DateTime? startTime,
    DateTime? endTime,
    GameResult? result,
    int? round,
    Map<String, bool>? callingStatus,
  }) {
    return GameModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      state: state ?? this.state,
      config: config ?? this.config,
      players: players ?? this.players,
      bottomCards: bottomCards ?? this.bottomCards,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      landlordId: landlordId ?? this.landlordId,
      playHistory: playHistory ?? this.playHistory,
      lastPlay: lastPlay ?? this.lastPlay,
      currentMultiplier: currentMultiplier ?? this.currentMultiplier,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      result: result ?? this.result,
      round: round ?? this.round,
      callingStatus: callingStatus ?? this.callingStatus,
    );
  }

  // 更新玩家
  GameModel updatePlayer(PlayerModel updatedPlayer) {
    final updatedPlayers = players.map((p) {
      return p.id == updatedPlayer.id ? updatedPlayer : p;
    }).toList();
    return copyWith(players: updatedPlayers);
  }

  // 添加出牌记录
  GameModel addPlayRecord(PlayRecord record) {
    final updatedHistory = [...playHistory, record];
    return copyWith(
      playHistory: updatedHistory,
      lastPlay: record,
    );
  }

  // 设置下一个玩家
  GameModel setNextPlayer() {
    if (currentPlayerId == null) return this;
    final nextPlayer = getNextPlayer(currentPlayerId!);
    return copyWith(currentPlayerId: nextPlayer?.id);
  }

  // JSON序列化
  factory GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);
  Map<String, dynamic> toJson() => _$GameModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        roomId,
        state,
        config,
        players,
        bottomCards,
        currentPlayerId,
        landlordId,
        playHistory,
        lastPlay,
        currentMultiplier,
        startTime,
        endTime,
        result,
        round,
        callingStatus,
      ];

  @override
  String toString() {
    return 'GameModel(id: $id, state: $state, players: ${players.length})';
  }
}

// 房间模型
@JsonSerializable()
class RoomModel extends Equatable {
  final String id;                    // 房间ID
  final String name;                  // 房间名称
  final String ownerId;               // 房主ID
  final GameConfig config;            // 游戏配置
  final List<PlayerModel> players;    // 玩家列表
  final bool isPrivate;               // 是否私人房间
  final String? password;             // 房间密码
  final DateTime createTime;          // 创建时间
  final GameModel? currentGame;       // 当前游戏

  const RoomModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.config,
    required this.players,
    this.isPrivate = false,
    this.password,
    required this.createTime,
    this.currentGame,
  });

  // 是否已满
  bool get isFull => players.length >= config.maxPlayers;

  // 是否可以开始游戏
  bool get canStartGame => players.length >= 3 && players.every((p) => p.isReady);

  factory RoomModel.fromJson(Map<String, dynamic> json) => _$RoomModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoomModelToJson(this);

  @override
  List<Object?> get props => [id, name, ownerId, config, players, isPrivate, password, createTime, currentGame];
}