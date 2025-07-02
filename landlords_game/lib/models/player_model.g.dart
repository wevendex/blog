// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerLevel _$PlayerLevelFromJson(Map<String, dynamic> json) => PlayerLevel(
      level: (json['level'] as num).toInt(),
      experience: (json['experience'] as num).toInt(),
      expToNext: (json['expToNext'] as num).toInt(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$PlayerLevelToJson(PlayerLevel instance) =>
    <String, dynamic>{
      'level': instance.level,
      'experience': instance.experience,
      'expToNext': instance.expToNext,
      'title': instance.title,
    };

PlayerStats _$PlayerStatsFromJson(Map<String, dynamic> json) => PlayerStats(
      totalGames: (json['totalGames'] as num).toInt(),
      winGames: (json['winGames'] as num).toInt(),
      loseGames: (json['loseGames'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
      bestStreak: (json['bestStreak'] as num).toInt(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      totalCoins: (json['totalCoins'] as num).toInt(),
    );

Map<String, dynamic> _$PlayerStatsToJson(PlayerStats instance) =>
    <String, dynamic>{
      'totalGames': instance.totalGames,
      'winGames': instance.winGames,
      'loseGames': instance.loseGames,
      'winRate': instance.winRate,
      'bestStreak': instance.bestStreak,
      'currentStreak': instance.currentStreak,
      'totalCoins': instance.totalCoins,
    };

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) => PlayerModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
      role: $enumDecodeNullable(_$PlayerRoleEnumMap, json['role']) ??
          PlayerRole.unknown,
      status: $enumDecodeNullable(_$PlayerStatusEnumMap, json['status']) ??
          PlayerStatus.waiting,
      level: PlayerLevel.fromJson(json['level'] as Map<String, dynamic>),
      stats: PlayerStats.fromJson(json['stats'] as Map<String, dynamic>),
      cards: (json['cards'] as List<dynamic>?)
              ?.map((e) => CardModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isBot: json['isBot'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? true,
      lastActiveTime: DateTime.parse(json['lastActiveTime'] as String),
      seatIndex: (json['seatIndex'] as num?)?.toInt() ?? -1,
      isReady: json['isReady'] as bool? ?? false,
      hasCalledLandlord: json['hasCalledLandlord'] as bool? ?? false,
      hasPassed: json['hasPassed'] as bool? ?? false,
    );

Map<String, dynamic> _$PlayerModelToJson(PlayerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'role': _$PlayerRoleEnumMap[instance.role]!,
      'status': _$PlayerStatusEnumMap[instance.status]!,
      'level': instance.level,
      'stats': instance.stats,
      'cards': instance.cards,
      'isBot': instance.isBot,
      'isOnline': instance.isOnline,
      'lastActiveTime': instance.lastActiveTime.toIso8601String(),
      'seatIndex': instance.seatIndex,
      'isReady': instance.isReady,
      'hasCalledLandlord': instance.hasCalledLandlord,
      'hasPassed': instance.hasPassed,
    };

const _$PlayerRoleEnumMap = {
  PlayerRole.farmer: 'farmer',
  PlayerRole.landlord: 'landlord',
  PlayerRole.unknown: 'unknown',
};

const _$PlayerStatusEnumMap = {
  PlayerStatus.waiting: 'waiting',
  PlayerStatus.ready: 'ready',
  PlayerStatus.playing: 'playing',
  PlayerStatus.thinking: 'thinking',
  PlayerStatus.offline: 'offline',
  PlayerStatus.finished: 'finished',
};
