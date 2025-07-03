import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_model.dart';
import '../models/player_model.dart';
import '../models/card_model.dart';
import '../core/services/audio_service.dart';

// 游戏控制器状态
class GameControllerState {
  final GameModel? currentGame;
  final String? currentPlayerId;
  final int timeRemaining;
  final bool isAutoPlaying;
  final String? error;

  const GameControllerState({
    this.currentGame,
    this.currentPlayerId,
    this.timeRemaining = 30,
    this.isAutoPlaying = false,
    this.error,
  });

  GameControllerState copyWith({
    GameModel? currentGame,
    String? currentPlayerId,
    int? timeRemaining,
    bool? isAutoPlaying,
    String? error,
  }) {
    return GameControllerState(
      currentGame: currentGame ?? this.currentGame,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isAutoPlaying: isAutoPlaying ?? this.isAutoPlaying,
      error: error ?? this.error,
    );
  }
}

// 游戏控制器
class GameController extends StateNotifier<GameControllerState> {
  Timer? _turnTimer;
  
  GameController() : super(const GameControllerState());

  // 初始化游戏
  void initializeGame(String gameId) {
    // 创建模拟游戏数据
    final players = [
      PlayerModel.initial(
        id: 'player1',
        nickname: '玩家1',
        avatar: 'assets/images/avatars/player1.png',
      ).copyWith(
        seatIndex: 0,
        cards: _generateRandomCards(17),
        role: PlayerRole.farmer,
      ),
      PlayerModel.bot(
        id: 'bot1',
        nickname: '电脑玩家1',
        seatIndex: 1,
      ).copyWith(
        cards: _generateRandomCards(17),
        role: PlayerRole.landlord,
      ),
      PlayerModel.bot(
        id: 'bot2',
        nickname: '电脑玩家2',
        seatIndex: 2,
      ).copyWith(
        cards: _generateRandomCards(17),
        role: PlayerRole.farmer,
      ),
    ];

    final game = GameModel.create(
      id: gameId,
      roomId: 'room1',
      players: players,
      config: const GameConfig(timeLimit: 30),
    ).copyWith(
      state: GameState.playing,
      currentPlayerId: 'player1',
      landlordId: 'bot1',
      bottomCards: _generateRandomCards(3),
    );

    state = state.copyWith(
      currentGame: game,
      currentPlayerId: game.currentPlayerId,
    );

    _startTurnTimer();
  }

  // 生成随机卡牌
  List<CardModel> _generateRandomCards(int count) {
    final random = Random();
    final suits = [CardSuit.spades, CardSuit.hearts, CardSuit.diamonds, CardSuit.clubs];
    final ranks = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]; // 3到A和2
    final cards = <CardModel>[];

    for (int i = 0; i < count; i++) {
      final suit = suits[random.nextInt(suits.length)];
      final rank = ranks[random.nextInt(ranks.length)];
      
      // 有小概率生成王牌
      if (random.nextDouble() < 0.05) {
        if (random.nextBool()) {
          cards.add(CardModel.smallJoker());
        } else {
          cards.add(CardModel.bigJoker());
        }
      } else {
        cards.add(CardModel.normal(
          suit: suit,
          rank: rank,
        ));
      }
    }

    return cards;
  }

  // 开始回合计时
  void _startTurnTimer() {
    _turnTimer?.cancel();
    state = state.copyWith(timeRemaining: state.currentGame?.config.timeLimit ?? 30);
    
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        _handleTimeOut();
        timer.cancel();
      }
    });
  }

  // 处理超时
  void _handleTimeOut() {
    if (state.currentGame == null || state.currentPlayerId == null) return;
    
    final currentPlayer = state.currentGame!.players
        .where((p) => p.id == state.currentPlayerId)
        .firstOrNull;
    
    if (currentPlayer == null) return;

    // 如果是机器人或者人类玩家，自动出牌
    if (currentPlayer.isBot || !currentPlayer.isBot) {
      _autoPlay(currentPlayer);
    }
  }

  // 自动出牌算法
  void _autoPlay(PlayerModel player) {
    if (state.currentGame == null) return;

    state = state.copyWith(isAutoPlaying: true);
    AudioService().playCardPlay();

    // 简单的自动出牌算法：随机选择1-3张牌
    final random = Random();
    final cardCount = min(3, player.cards.length);
    final playCount = cardCount > 0 ? random.nextInt(cardCount) + 1 : 0;
    
    if (playCount > 0 && player.cards.isNotEmpty) {
      final cardsToPlay = player.cards.take(playCount).toList();
      _playCards(player.id, cardsToPlay);
    } else {
      _pass(player.id);
    }

    // 延迟恢复状态
    Timer(const Duration(milliseconds: 1500), () {
      state = state.copyWith(isAutoPlaying: false);
    });
  }

  // 出牌
  void playCards(String playerId, List<CardModel> cards) {
    if (state.currentGame == null || playerId != state.currentPlayerId) return;
    _playCards(playerId, cards);
  }

  void _playCards(String playerId, List<CardModel> cards) {
    if (state.currentGame == null) return;

    final game = state.currentGame!;
    final player = game.players.where((p) => p.id == playerId).firstOrNull;
    if (player == null) return;

    // 更新玩家手牌
    final updatedPlayer = player.removeCards(cards);
    final updatedGame = game.updatePlayer(updatedPlayer);

    // 创建出牌记录
    final playRecord = PlayRecord(
      playerId: playerId,
      cards: cards,
      playType: _determinePlayType(cards),
      timestamp: DateTime.now(),
    );

    final finalGame = updatedGame.addPlayRecord(playRecord).setNextPlayer();

    state = state.copyWith(
      currentGame: finalGame,
      currentPlayerId: finalGame.currentPlayerId,
    );

    _startTurnTimer();
  }

  // 过牌
  void pass(String playerId) {
    if (state.currentGame == null || playerId != state.currentPlayerId) return;
    _pass(playerId);
  }

  void _pass(String playerId) {
    if (state.currentGame == null) return;

    final game = state.currentGame!;
    final playRecord = PlayRecord.pass(playerId);
    final updatedGame = game.addPlayRecord(playRecord).setNextPlayer();

    state = state.copyWith(
      currentGame: updatedGame,
      currentPlayerId: updatedGame.currentPlayerId,
    );

    _startTurnTimer();
  }

  // 确定出牌类型（简化版）
  PlayType _determinePlayType(List<CardModel> cards) {
    switch (cards.length) {
      case 1:
        return PlayType.single;
      case 2:
        return PlayType.pair;
      case 3:
        return PlayType.triple;
      default:
        return PlayType.straight;
    }
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }
}

// Provider
final gameControllerProvider = StateNotifierProvider<GameController, GameControllerState>((ref) {
  return GameController();
});