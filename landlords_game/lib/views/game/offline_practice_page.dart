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
      child: Container(
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
      child: SizedBox(
        height: 80.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: _playerHand.length,
          itemBuilder: (_, i) => _buildCardBack(),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
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

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 20.h,
      left: 20.w,
      right: 20.w,
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              onPressed: () => AudioService().playButtonClick(),
              height: 44.h,
              backgroundColor: Colors.grey,
              child: Text('过', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomButton(
              onPressed: _isMyTurn ? () => AudioService().playCardPlay() : null,
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
}