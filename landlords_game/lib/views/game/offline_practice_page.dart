import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/themes/app_theme.dart';
import '../../core/services/audio_service.dart';
import '../../widgets/custom_button.dart';
import '../../models/card_model.dart';

/// 离线三人对战页面
class OfflinePracticePage extends StatefulWidget {
  const OfflinePracticePage({super.key});

  @override
  State<OfflinePracticePage> createState() => _OfflinePracticePageState();
}

class _OfflinePracticePageState extends State<OfflinePracticePage> {
  late List<CardModel> _playerHand;
  late List<CardModel> _leftHand;
  late List<CardModel> _rightHand;
  late List<CardModel> _bottomCards;

  bool _isMyTurn = true;
  String _currentPlayer = 'player'; // player, left, right

  List<CardModel> _currentTrick = [];
  String? _lastPlayedBy;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    // 生成一副牌并洗牌
    final deck = CardFactory.shuffleDeck(CardFactory.createFullDeck());

    // 发牌：每人17张，底牌3张
    _playerHand = deck.sublist(0, 17);
    _leftHand = deck.sublist(17, 34);
    _rightHand = deck.sublist(34, 51);
    _bottomCards = deck.sublist(51);

    // 随机决定先手，这里固定玩家先手
    _currentPlayer = 'player';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.gameBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildTopPlayer(),
                    _buildLeftPlayer(),
                    _buildRightPlayer(),
                    _buildPlayArea(),
                    _buildBottomCards(),
                    _buildPlayerCards(),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
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
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 8.w),
          Text(
            '离线练习',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.goldColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(String name, int cardCount, bool isCurrent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isCurrent ? AppTheme.goldColor : Colors.white24,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppTheme.goldColor,
            child: Icon(Icons.person, size: 20.sp, color: Colors.black),
          ),
          SizedBox(width: 8.w),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              Text('$cardCount张',
                  style: TextStyle(fontSize: 10.sp, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlayer() {
    return Positioned(
      top: 20.h,
      left: 0,
      right: 0,
      child: Center(child: _buildPlayerInfo('电脑玩家1', _leftHand.length, false)),
    );
  }

  Widget _buildLeftPlayer() {
    return Positioned(
      left: 20.w,
      top: 100.h,
      child: Transform.rotate(
        angle: 1.57,
        child: _buildPlayerInfo('电脑玩家2', _rightHand.length, false),
      ),
    );
  }

  Widget _buildRightPlayer() {
    return Positioned(
      right: 20.w,
      top: 100.h,
      child: Transform.rotate(
        angle: -1.57,
        child: _buildPlayerInfo('当前玩家', _playerHand.length, true),
      ),
    );
  }

  Widget _buildPlayArea() {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentTrick.isEmpty
            ? Container(
                key: const ValueKey('empty'),
                width: 200.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Center(
                  child: Text('出牌区', style: TextStyle(fontSize: 16.sp, color: Colors.white54)),
                ),
              )
            : Container(
                key: ValueKey(_currentTrick.hashCode),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppTheme.goldColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _currentTrick
                      .map((c) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(c.displayName,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: c.isRed ? Colors.red : Colors.white)),
                          ))
                      .toList(),
                ),
              ),
      ),
    );
  }

  Widget _buildBottomCards() {
    return Positioned(
      top: 80.h,
      right: 20.w,
      child: Column(
        children: [
          Text('底牌', style: TextStyle(fontSize: 12.sp, color: AppTheme.goldColor, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Row(
            children: _bottomCards.map((c) => _buildCardMini(c)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardMini(CardModel card) {
    return Container(
      width: 30.w,
      height: 40.h,
      margin: EdgeInsets.only(right: 2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.black26),
      ),
      child: Center(
        child: Text(card.displayName,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
              color: card.isRed ? Colors.red : Colors.black,
            )),
      ),
    );
  }

  Widget _buildPlayerCards() {
    return Positioned(
      bottom: 80.h,
      left: 0,
      right: 0,
      child: RepaintBoundary(
        child: SizedBox(
          height: 80.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            cacheExtent: 400,
            itemCount: _playerHand.length,
            itemBuilder: (_, i) => _buildCardBack(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack() => const _CardBack();

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 20.h,
      left: 20.w,
      right: 20.w,
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              onPressed: _isMyTurn ? _handlePass : null,
              height: 44.h,
              backgroundColor: Colors.grey,
              child: Text('过', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomButton(
              onPressed: _isMyTurn ? _handlePlayerPlay : null,
              height: 44.h,
              child: Text('出牌', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomButton(
              onPressed: () => AudioService().playButtonClick(),
              height: 44.h,
              backgroundColor: Colors.orange,
              child: Text('提示', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // =================  游戏逻辑  =================

  void _handlePlayerPlay() {
    if (_playerHand.isEmpty) return;
    final card = _playerHand.removeAt(0);
    _playCards('player', [card]);
  }

  void _handlePass() {
    _nextTurn();
  }

  void _playCards(String actor, List<CardModel> cards) {
    setState(() {
      _currentTrick = cards;
      _lastPlayedBy = actor;
    });
    AudioService().playCardPlay();

    // 判断胜利
    if (_playerHand.isEmpty || _leftHand.isEmpty || _rightHand.isEmpty) {
      _showWinDialog(actor);
      return;
    }

    _nextTurn();
  }

  void _nextTurn() {
    setState(() {
      if (_currentPlayer == 'player') {
        _currentPlayer = 'left';
      } else if (_currentPlayer == 'left') {
        _currentPlayer = 'right';
      } else {
        _currentPlayer = 'player';
      }

      _isMyTurn = _currentPlayer == 'player';
    });

    if (!_isMyTurn) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _aiPlay(_currentPlayer);
      });
    }
  }

  void _aiPlay(String actor) {
    List<CardModel> hand;
    if (actor == 'left') {
      hand = _leftHand;
    } else {
      hand = _rightHand;
    }

    if (hand.isEmpty) return;

    // 简易 AI：总是出第一张
    final card = hand.removeAt(0);
    _playCards(actor, [card]);
  }

  void _showWinDialog(String winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text('游戏结束', style: TextStyle(color: AppTheme.goldColor)),
        content: Text('$winner 获胜！', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }
}

// ======= 小部件 =======

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45.w,
      height: 70.h,
      margin: EdgeInsets.only(right: 2.w),
      decoration: BoxDecoration(
        gradient: AppTheme.cardBackgroundGradient,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
    );
  }
}