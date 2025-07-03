import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_theme.dart';
import '../../core/services/audio_service.dart';
import '../../widgets/custom_button.dart';
import '../../controllers/game_controller.dart';
import '../../models/game_model.dart';
import '../../models/player_model.dart';
import '../../models/card_model.dart';

class GamePlayPage extends ConsumerStatefulWidget {
  final String gameId;
  
  const GamePlayPage({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends ConsumerState<GamePlayPage> {
  final List<String> selectedCards = [];

  @override
  void initState() {
    super.initState();
    // 初始化游戏
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameControllerProvider.notifier).initializeGame(widget.gameId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final game = gameState.currentGame;

    if (game == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.gameBackgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // 顶部信息栏
                  _buildTopBar(),
                  
                  // 游戏区域
                  Expanded(
                    child: Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight - 100.h,
                      child: Stack(
                        children: [
                          // 上方玩家 (座位1)
                          _buildTopPlayer(game, gameState),
                          
                          // 左侧玩家 (座位2)
                          _buildLeftPlayer(game, gameState),
                          
                          // 右侧玩家 (座位0 - 当前玩家)
                          _buildRightPlayer(game, gameState),
                          
                          // 中央出牌区
                          _buildPlayArea(game),
                          
                          // 底牌显示
                          _buildBottomCards(game),
                          
                          // 倒计时显示
                          _buildTimer(gameState),
                          
                          // 当前玩家手牌区
                          _buildPlayerCards(game),
                        ],
                      ),
                    ),
                  ),
                  
                  // 操作按钮
                  _buildActionButtons(game, gameState),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.goldColor),
            onPressed: () {
              AudioService().playButtonClick();
              _showExitDialog();
            },
          ),
          SizedBox(width: 8.w),
          Text(
            '斗地主游戏',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.goldColor,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.volume_up,
            color: AppTheme.goldColor,
            size: 20.sp,
          ),
          SizedBox(width: 16.w),
          Icon(
            Icons.settings,
            color: AppTheme.goldColor,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlayer(GameModel game, GameControllerState gameState) {
    final player = game.players.where((p) => p.seatIndex == 1).firstOrNull;
    if (player == null) return const SizedBox.shrink();

    return Positioned(
      top: 20.h,
      left: 50.w,
      right: 50.w,
      child: Column(
        children: [
          _buildPlayerInfo(player, gameState.currentPlayerId == player.id),
          SizedBox(height: 8.h),
          // 显示玩家的牌背
          _buildOpponentCards(player, true),
        ],
      ),
    );
  }

  Widget _buildLeftPlayer(GameModel game, GameControllerState gameState) {
    final player = game.players.where((p) => p.seatIndex == 2).firstOrNull;
    if (player == null) return const SizedBox.shrink();

    return Positioned(
      left: 10.w,
      top: 120.h,
      bottom: 200.h,
      child: Column(
        children: [
          Transform.rotate(
            angle: 1.57, // 90度
            child: _buildPlayerInfo(player, gameState.currentPlayerId == player.id),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: _buildOpponentCards(player, false),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPlayer(GameModel game, GameControllerState gameState) {
    final player = game.players.where((p) => p.seatIndex == 0).firstOrNull;
    if (player == null) return const SizedBox.shrink();

    return Positioned(
      right: 10.w,
      top: 120.h,
      bottom: 200.h,
      child: Column(
        children: [
          Transform.rotate(
            angle: -1.57, // -90度
            child: _buildPlayerInfo(player, gameState.currentPlayerId == player.id),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: _buildOpponentCards(player, false),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(PlayerModel player, bool isCurrentTurn) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isCurrentTurn ? AppTheme.goldColor : Colors.white24,
          width: isCurrentTurn ? 3 : 1,
        ),
        boxShadow: isCurrentTurn ? [
          BoxShadow(
            color: AppTheme.goldColor.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: player.isLandlord ? Colors.red : AppTheme.goldColor,
            child: Icon(
              player.isLandlord ? Icons.crown : Icons.person,
              size: 20.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.nickname,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${player.cardCount}张',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white70,
                ),
              ),
              if (player.isLandlord)
                Text(
                  '地主',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentCards(PlayerModel player, bool isHorizontal) {
    final cardCount = player.cardCount;
    if (cardCount == 0) return const SizedBox.shrink();

    if (isHorizontal) {
      // 水平排列（上方玩家）
      return SizedBox(
        height: 50.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            min(cardCount, 13), // 最多显示13张
            (index) => Container(
              width: 24.w,
              height: 40.h,
              margin: EdgeInsets.only(right: index < min(cardCount, 13) - 1 ? -8.w : 0),
              decoration: BoxDecoration(
                color: Colors.blue.shade800,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Center(
                child: Icon(
                  Icons.style,
                  size: 12.sp,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // 垂直排列（左右玩家）
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          min(cardCount, 10), // 最多显示10张
          (index) => Container(
            width: 30.w,
            height: 20.h,
            margin: EdgeInsets.only(bottom: index < min(cardCount, 10) - 1 ? -6.h : 0),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(3.r),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Center(
              child: Icon(
                Icons.style,
                size: 8.sp,
                color: Colors.white54,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPlayArea(GameModel game) {
    return Center(
      child: Container(
        width: 250.w,
        height: 100.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (game.lastPlay != null && !game.lastPlay!.isPassed) ...[
              Text(
                '最后出牌',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 4.h),
              Wrap(
                children: game.lastPlay!.cards.map((card) {
                  return Container(
                    width: 30.w,
                    height: 40.h,
                    margin: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.black26, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        _getCardDisplay(card),
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: _getCardColor(card),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              Text(
                '出牌区',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCards(GameModel game) {
    if (game.bottomCards.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 80.h,
      right: 20.w,
      child: Column(
        children: [
          Text(
            '底牌',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.goldColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: game.bottomCards.map((card) {
              return Container(
                width: 30.w,
                height: 40.h,
                margin: EdgeInsets.only(right: 2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.black26, width: 1),
                ),
                child: Center(
                  child: Text(
                    _getCardDisplay(card),
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      color: _getCardColor(card),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(GameControllerState gameState) {
    return Positioned(
      top: 60.h,
      left: 20.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: gameState.timeRemaining <= 10 ? Colors.red : AppTheme.goldColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer,
              size: 16.sp,
              color: Colors.white,
            ),
            SizedBox(width: 4.w),
            Text(
              '${gameState.timeRemaining}秒',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCards(GameModel game) {
    final currentPlayer = game.players.where((p) => p.seatIndex == 0).firstOrNull;
    if (currentPlayer == null || currentPlayer.cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 80.h,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 90.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: currentPlayer.cards.length,
          itemBuilder: (context, index) {
            final card = currentPlayer.cards[index];
            final isSelected = selectedCards.contains(card.id);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedCards.remove(card.id);
                  } else {
                    selectedCards.add(card.id);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(0, isSelected ? -10.h : 0, 0),
                width: 45.w,
                height: 70.h,
                margin: EdgeInsets.only(right: 2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected ? AppTheme.goldColor : Colors.black26,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getCardDisplay(card),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: _getCardColor(card),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(GameModel game, GameControllerState gameState) {
    final isMyTurn = gameState.currentPlayerId == 'player1';
    final currentPlayer = game.players.where((p) => p.id == 'player1').firstOrNull;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              onPressed: isMyTurn ? () {
                AudioService().playButtonClick();
                ref.read(gameControllerProvider.notifier).pass('player1');
                setState(() {
                  selectedCards.clear();
                });
              } : null,
              height: 44.h,
              backgroundColor: Colors.grey,
              child: Text(
                '过',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomButton(
              onPressed: isMyTurn && selectedCards.isNotEmpty ? () {
                AudioService().playCardPlay();
                final cardsToPlay = currentPlayer!.cards
                    .where((card) => selectedCards.contains(card.id))
                    .toList();
                ref.read(gameControllerProvider.notifier).playCards('player1', cardsToPlay);
                setState(() {
                  selectedCards.clear();
                });
              } : null,
              height: 44.h,
              child: Text(
                '出牌',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomButton(
              onPressed: () {
                AudioService().playButtonClick();
                // TODO: 实现提示逻辑
              },
              height: 44.h,
              backgroundColor: Colors.orange,
              child: Text(
                '提示',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCardDisplay(CardModel card) {
    return card.displayName;
  }

  Color _getCardColor(CardModel card) {
    if (card.isJoker) {
      return card.type == CardType.jokerSmall ? Colors.red : Colors.black;
    }
    return card.isRed ? Colors.red : Colors.black;
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          '退出游戏',
          style: TextStyle(
            color: AppTheme.goldColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '确定要退出当前游戏吗？退出将被视为认输。',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            ),
          ),
          CustomButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('确定退出'),
          ),
        ],
      ),
    );
  }
}