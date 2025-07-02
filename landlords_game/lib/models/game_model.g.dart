// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameConfig _$GameConfigFromJson(Map<String, dynamic> json) => GameConfig(
      type: $enumDecodeNullable(_$GameTypeEnumMap, json['type']) ??
          GameType.classic,
      difficulty:
          $enumDecodeNullable(_$GameDifficultyEnumMap, json['difficulty']) ??
              GameDifficulty.normal,
      baseScore: (json['baseScore'] as num?)?.toInt() ?? 100,
      multiplier: (json['multiplier'] as num?)?.toInt() ?? 1,
      allowRocket: json['allowRocket'] as bool? ?? true,
      allowBomb: json['allowBomb'] as bool? ?? true,
      maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 3,
      timeLimit: (json['timeLimit'] as num?)?.toInt() ?? 30,
    );

Map<String, dynamic> _$GameConfigToJson(GameConfig instance) =>
    <String, dynamic>{
      'type': _$GameTypeEnumMap[instance.type]!,
      'difficulty': _$GameDifficultyEnumMap[instance.difficulty]!,
      'baseScore': instance.baseScore,
      'multiplier': instance.multiplier,
      'allowRocket': instance.allowRocket,
      'allowBomb': instance.allowBomb,
      'maxPlayers': instance.maxPlayers,
      'timeLimit': instance.timeLimit,
    };

const _$GameTypeEnumMap = {
  GameType.classic: 'classic',
  GameType.happy: 'happy',
  GameType.tournament: 'tournament',
  GameType.quick: 'quick',
};

const _$GameDifficultyEnumMap = {
  GameDifficulty.easy: 'easy',
  GameDifficulty.normal: 'normal',
  GameDifficulty.hard: 'hard',
};

PlayRecord _$PlayRecordFromJson(Map<String, dynamic> json) => PlayRecord(
      playerId: json['playerId'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      playType: $enumDecode(_$PlayTypeEnumMap, json['playType']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPassed: json['isPassed'] as bool? ?? false,
    );

Map<String, dynamic> _$PlayRecordToJson(PlayRecord instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'cards': instance.cards,
      'playType': _$PlayTypeEnumMap[instance.playType]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'isPassed': instance.isPassed,
    };

const _$PlayTypeEnumMap = {
  PlayType.single: 'single',
  PlayType.pair: 'pair',
  PlayType.triple: 'triple',
  PlayType.tripleWithSingle: 'triple_with_single',
  PlayType.tripleWithPair: 'triple_with_pair',
  PlayType.straight: 'straight',
  PlayType.pairStraight: 'pair_straight',
  PlayType.plane: 'plane',
  PlayType.planeWithSingle: 'plane_with_single',
  PlayType.planeWithPair: 'plane_with_pair',
  PlayType.bomb: 'bomb',
  PlayType.rocket: 'rocket',
  PlayType.fourWithTwo: 'four_with_two',
  PlayType.invalid: 'invalid',
};

GameResult _$GameResultFromJson(Map<String, dynamic> json) => GameResult(
      winnerId: json['winnerId'] as String,
      winnerTeam: (json['winnerTeam'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      scores: Map<String, int>.from(json['scores'] as Map),
      coins: Map<String, int>.from(json['coins'] as Map),
      duration: (json['duration'] as num).toInt(),
      finishTime: DateTime.parse(json['finishTime'] as String),
    );

Map<String, dynamic> _$GameResultToJson(GameResult instance) =>
    <String, dynamic>{
      'winnerId': instance.winnerId,
      'winnerTeam': instance.winnerTeam,
      'scores': instance.scores,
      'coins': instance.coins,
      'duration': instance.duration,
      'finishTime': instance.finishTime.toIso8601String(),
    };

GameModel _$GameModelFromJson(Map<String, dynamic> json) => GameModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      state: $enumDecode(_$GameStateEnumMap, json['state']),
      config: GameConfig.fromJson(json['config'] as Map<String, dynamic>),
      players: (json['players'] as List<dynamic>)
          .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      bottomCards: (json['bottomCards'] as List<dynamic>?)
              ?.map((e) => CardModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentPlayerId: json['currentPlayerId'] as String?,
      landlordId: json['landlordId'] as String?,
      playHistory: (json['playHistory'] as List<dynamic>?)
              ?.map((e) => PlayRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastPlay: json['lastPlay'] == null
          ? null
          : PlayRecord.fromJson(json['lastPlay'] as Map<String, dynamic>),
      currentMultiplier: (json['currentMultiplier'] as num?)?.toInt() ?? 1,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      result: json['result'] == null
          ? null
          : GameResult.fromJson(json['result'] as Map<String, dynamic>),
      round: (json['round'] as num?)?.toInt() ?? 0,
      callingStatus: (json['callingStatus'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$GameModelToJson(GameModel instance) => <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'state': _$GameStateEnumMap[instance.state]!,
      'config': instance.config,
      'players': instance.players,
      'bottomCards': instance.bottomCards,
      'currentPlayerId': instance.currentPlayerId,
      'landlordId': instance.landlordId,
      'playHistory': instance.playHistory,
      'lastPlay': instance.lastPlay,
      'currentMultiplier': instance.currentMultiplier,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'result': instance.result,
      'round': instance.round,
      'callingStatus': instance.callingStatus,
    };

const _$GameStateEnumMap = {
  GameState.waiting: 'waiting',
  GameState.ready: 'ready',
  GameState.dealing: 'dealing',
  GameState.calling: 'calling',
  GameState.playing: 'playing',
  GameState.finished: 'finished',
  GameState.paused: 'paused',
};

RoomModel _$RoomModelFromJson(Map<String, dynamic> json) => RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      config: GameConfig.fromJson(json['config'] as Map<String, dynamic>),
      players: (json['players'] as List<dynamic>)
          .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPrivate: json['isPrivate'] as bool? ?? false,
      password: json['password'] as String?,
      createTime: DateTime.parse(json['createTime'] as String),
      currentGame: json['currentGame'] == null
          ? null
          : GameModel.fromJson(json['currentGame'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoomModelToJson(RoomModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerId': instance.ownerId,
      'config': instance.config,
      'players': instance.players,
      'isPrivate': instance.isPrivate,
      'password': instance.password,
      'createTime': instance.createTime.toIso8601String(),
      'currentGame': instance.currentGame,
    };
