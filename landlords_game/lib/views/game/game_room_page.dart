import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_theme.dart';
import '../../core/services/audio_service.dart';
import '../../widgets/custom_button.dart';
import '../../models/player_model.dart';

class GameRoomPage extends StatefulWidget {
  final String roomId;
  
  const GameRoomPage({
    super.key,
    required this.roomId,
  });

  @override
  State<GameRoomPage> createState() => _GameRoomPageState();
}

class _GameRoomPageState extends State<GameRoomPage> {
  late List<PlayerModel?> players;
  bool isReady = false;
  int countdown = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  void _initializePlayers() {
    // 模拟三个玩家位置
    players = [
      PlayerModel.initial(
        id: 'player_1',
        nickname: '当前玩家',
      ),
      PlayerModel.bot(
        id: 'bot_1',
        nickname: '电脑玩家1',
        seatIndex: 1,
      ),
      PlayerModel.bot(
        id: 'bot_2',
        nickname: '电脑玩家2',
        seatIndex: 2,
      ),
    ];
  }

  void _toggleReady() {
    setState(() {
      isReady = !isReady;
    });
    
    AudioService().playButtonClick();
    
    if (isReady && _allPlayersReady()) {
      _startCountdown();
    }
  }

  bool _allPlayersReady() {
    return true; // 简化逻辑，假设所有玩家都准备好了
  }

  void _startCountdown() {
    setState(() => countdown = 3);
    
    Stream.periodic(const Duration(seconds: 1), (count) => 3 - count - 1)
        .take(3)
        .listen((time) {
      if (mounted) {
        setState(() => countdown = time);
      }
    }).onDone(() {
      if (mounted) {
        _startGame();
      }
    });
  }

  void _startGame() {
    AudioService().playButtonClick();
    context.go('/game-play/mock_game_123');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('房间: ${widget.roomId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService().playButtonClick();
            context.pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.gameBackgroundGradient,
        ),
        child: Column(
          children: [
            // 房间信息
            _buildRoomInfo(),
            
            SizedBox(height: 20.h),
            
            // 玩家座位
            Expanded(
              child: _buildPlayerSeats(),
            ),
            
            // 倒计时提示
            if (countdown > 0) _buildCountdown(),
            
            // 底部操作区
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.goldColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.home,
            size: 24.sp,
            color: AppTheme.goldColor,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '经典模式',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '底分: 100',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: AppTheme.goldColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '3/3',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.goldColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSeats() {
    return Column(
      children: [
        // 上方玩家
        _buildPlayerSeat(players[1], 1),
        
        SizedBox(height: 40.h),
        
        // 左右玩家
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPlayerSeat(players[2], 2),
            _buildPlayerSeat(players[0], 0),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerSeat(PlayerModel? player, int seatIndex) {
    final isCurrentPlayer = seatIndex == 0;
    final playerReady = isCurrentPlayer ? isReady : true;
    
    return Container(
      width: 120.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: playerReady 
              ? AppTheme.goldColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // 头像
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: playerReady ? AppTheme.goldColor : Colors.white54,
                width: 2,
              ),
              gradient: playerReady ? AppTheme.goldGradient : null,
              color: playerReady ? null : Colors.grey,
            ),
            child: Icon(
              Icons.person,
              size: 30.sp,
              color: playerReady ? Colors.black : Colors.white54,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          // 昵称
          Text(
            player?.nickname ?? '等待加入',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 4.h),
          
          // 状态
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 2.h,
            ),
            decoration: BoxDecoration(
              color: playerReady 
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              playerReady ? '已准备' : '等待中',
              style: TextStyle(
                fontSize: 10.sp,
                color: playerReady ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        children: [
          Text(
            '游戏即将开始',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.goldColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$countdown',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.goldColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          // 离开房间
          Expanded(
            child: CustomButton(
              onPressed: () {
                AudioService().playButtonClick();
                context.pop();
              },
              height: 48.h,
              backgroundColor: Colors.transparent,
              borderColor: Colors.white54,
              borderWidth: 1,
              child: Text(
                '离开房间',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // 准备/取消准备
          Expanded(
            flex: 2,
            child: CustomButton(
              onPressed: countdown > 0 ? null : _toggleReady,
              height: 48.h,
              backgroundColor: isReady 
                  ? Colors.orange 
                  : AppTheme.goldColor,
              child: Text(
                countdown > 0 
                    ? '游戏开始中...'
                    : isReady 
                        ? '取消准备' 
                        : '准备',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}