// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
      suit: $enumDecode(_$CardSuitEnumMap, json['suit']),
      rank: (json['rank'] as num).toInt(),
      type: $enumDecode(_$CardTypeEnumMap, json['type']),
      id: json['id'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
      isPlayable: json['isPlayable'] as bool? ?? true,
    );

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
      'suit': _$CardSuitEnumMap[instance.suit]!,
      'rank': instance.rank,
      'type': _$CardTypeEnumMap[instance.type]!,
      'id': instance.id,
      'isSelected': instance.isSelected,
      'isPlayable': instance.isPlayable,
    };

const _$CardSuitEnumMap = {
  CardSuit.spades: 'spades',
  CardSuit.hearts: 'hearts',
  CardSuit.diamonds: 'diamonds',
  CardSuit.clubs: 'clubs',
  CardSuit.joker: 'joker',
};

const _$CardTypeEnumMap = {
  CardType.normal: 'normal',
  CardType.jokerSmall: 'joker_small',
  CardType.jokerBig: 'joker_big',
};
