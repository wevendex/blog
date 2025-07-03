import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../core/themes/app_theme.dart';
import '../../core/services/audio_service.dart';
import '../../widgets/custom_button.dart';

class GamePlayPage extends StatefulWidget {
  final String gameId;
  
  const GamePlayPage({
    super.key,
    required this.gameId,
  });

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage> {
  // 添加回合倒计时相关变量
  Timer? _turnTimer;
  int _remainingTime = 15; // 每回合 15 秒
  
  bool isMyTurn = true;
  int playerCards = 17;
  int leftPlayerCards = 17;
  int rightPlayerCards = 17;
  List<String> bottomCards = ['大王', '小王', '2♠'];

  @override
  void initState() {
    super.initState();
    _startTurnTimer();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }

  void _startTurnTimer() {
    _turnTimer?.cancel();
    setState(() => _remainingTime = 15);

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        _autoPlay();
      }
    });
  }

  // 时间到自动出牌（简化为过牌示例）
  void _autoPlay() {
    if (!mounted) return;
    // TODO: 替换为真正的出牌算法
    setState(() {
      isMyTurn = false;
    });
    AudioService().playButtonClick();
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
              // 顶部信息栏
              _buildTopBar(),
              
              // 游戏区域
              Expanded(
                child: Stack(
                  children: [
                    // 上方玩家
                    _buildTopPlayer(),
                    
                    // 左侧玩家
                    _buildLeftPlayer(),
                    
                    // 右侧玩家
                    _buildRightPlayer(),
                    
                    // 中央出牌区
                    _buildPlayArea(),
                    
                    // 左侧玩家手牌
                    _buildLeftPlayerCards(),
                    
                    // 右侧玩家手牌
                    _buildRightPlayerCards(),
                    
                    // 上方玩家手牌
                    _buildTopPlayerCards(),
                    
                    // 底牌显示
                    _buildBottomCards(),
                    
                    // 当前玩家手牌区
                    _buildPlayerCards(),
                    
                    // 回合倒计时
                    _buildCountdown(),
                    
                    // 操作按钮
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
              _showExitDialog();
            },
          ),
          SizedBox(width: 8.w),
          Text(
            '游戏中',
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

  Widget _buildTopPlayer() {
    return Positioned(
      top: 20.h,
      left: 0,
      right: 0,
      child: Center(
        child: _buildPlayerInfo('电脑玩家1', leftPlayerCards, false),
      ),
    );
  }

  Widget _buildLeftPlayer() {
    return Positioned(
      left: 20.w,
      top: 100.h,
      child: Transform.rotate(
        angle: 1.57, // 90度
        child: _buildPlayerInfo('电脑玩家2', rightPlayerCards, false),
      ),
    );
  }

  Widget _buildRightPlayer() {
    return Positioned(
      right: 20.w,
      top: 100.h,
      child: Transform.rotate(
        angle: -1.57, // -90度
        child: _buildPlayerInfo('当前玩家', playerCards, true),
      ),
    );
  }

  Widget _buildPlayerInfo(String name, int cardCount, bool isCurrentPlayer) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isCurrentPlayer ? AppTheme.goldColor : Colors.white24,
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppTheme.goldColor,
            child: Icon(
              Icons.person,
              size: 20.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$cardCount张',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
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
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '出牌区',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white54,
            ),
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
            children: bottomCards.map((card) {
              return Container(
                width: 30.w,
                height: 40.h,
                margin: EdgeInsets.only(right: 2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: Colors.black26,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    card,
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      color: card.contains('♥') || card.contains('♦')
                          ? Colors.red
                          : Colors.black,
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
          itemCount: playerCards,
          itemBuilder: (context, index) {
            return Container(
              width: 45.w,
              height: 70.h,
              margin: EdgeInsets.only(right: 2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: Colors.black26,
                  width: 1,
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
                  '牌',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
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
              onPressed: () {
                AudioService().playButtonClick();
                // TODO: 实现过牌逻辑
              },
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
              onPressed: isMyTurn ? () {
                AudioService().playCardPlay();
                // TODO: 实现出牌逻辑
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

  Widget _buildCountdown() {
    if (!isMyTurn) return const SizedBox.shrink();
    return Positioned(
      bottom: 160.h,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '$_remainingTime',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.goldColor,
            ),
          ),
        ),
      ),
    );
  }

  // 生成一张背面朝上的牌
  Widget _buildCardBack({double width = 40, double height = 50}) {
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade200,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.black26, width: 1),
      ),
    );
  }

  // 左侧玩家手牌（纵向叠放）
  Widget _buildLeftPlayerCards() {
    final double overlap = 18.h;
    return Positioned(
      left: 12.w,
      top: MediaQuery.of(context).size.height * 0.25,
      child: SizedBox(
        width: 45.w,
        height: overlap * (leftPlayerCards - 1) + 60.h,
        child: Stack(
          children: List.generate(leftPlayerCards, (index) {
            return Positioned(
              top: index * overlap,
              child: _buildCardBack(width: 45, height: 60),
            );
          }),
        ),
      ),
    );
  }

  // 右侧玩家手牌（纵向叠放）
  Widget _buildRightPlayerCards() {
    final double overlap = 18.h;
    return Positioned(
      right: 12.w,
      top: MediaQuery.of(context).size.height * 0.25,
      child: SizedBox(
        width: 45.w,
        height: overlap * (rightPlayerCards - 1) + 60.h,
        child: Stack(
          children: List.generate(rightPlayerCards, (index) {
            return Positioned(
              top: index * overlap,
              child: _buildCardBack(width: 45, height: 60),
            );
          }),
        ),
      ),
    );
  }

  // 上方玩家手牌（横向叠放）
  Widget _buildTopPlayerCards() {
    final double overlap = 24.w;
    return Positioned(
      top: 60.h,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          height: 60.h,
          width: overlap * (leftPlayerCards - 1) + 45.w,
          child: Stack(
            children: List.generate(leftPlayerCards, (index) {
              return Positioned(
                left: index * overlap,
                child: _buildCardBack(width: 45, height: 60),
              );
            }),
          ),
        ),
      ),
    );
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