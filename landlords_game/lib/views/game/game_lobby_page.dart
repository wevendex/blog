import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_theme.dart';
import '../../core/services/audio_service.dart';
import '../../widgets/custom_button.dart';

class GameLobbyPage extends StatefulWidget {
  const GameLobbyPage({super.key});

  @override
  State<GameLobbyPage> createState() => _GameLobbyPageState();
}

class _GameLobbyPageState extends State<GameLobbyPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isMatching = false;
  int _matchingTime = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startMatching();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  void _startMatching() {
    setState(() => _isMatching = true);
    
    // 模拟匹配计时
    Stream.periodic(const Duration(seconds: 1), (count) => count)
        .take(10)
        .listen((count) {
      if (mounted) {
        setState(() => _matchingTime = count + 1);
      }
    }).onDone(() {
      if (mounted) {
        _showMatchResult();
      }
    });
  }

  void _showMatchResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          '匹配成功！',
          style: TextStyle(
            color: AppTheme.goldColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '找到对手了！准备开始游戏吧～',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          CustomButton(
            onPressed: () {
              Navigator.pop(context);
              // 跳转到游戏房间
              context.go('/game-room/mock_room_123');
            },
            child: const Text('进入游戏'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('游戏大厅'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 匹配状态图标
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.search,
                        size: 60.sp,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 40.h),
              
              // 匹配状态文字
              Text(
                _isMatching ? '正在匹配对手...' : '匹配完成',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldColor,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // 匹配时间
              Text(
                '匹配时间: ${_formatTime(_matchingTime)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white70,
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // 匹配提示
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppTheme.goldColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 24.sp,
                      color: AppTheme.goldColor,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      '匹配提示',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '系统正在为您匹配合适的对手，请耐心等待。匹配成功后将自动进入游戏房间。',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // 取消匹配按钮
              if (_isMatching)
                CustomButton(
                  onPressed: () {
                    AudioService().playButtonClick();
                    context.pop();
                  },
                  width: 200.w,
                  height: 44.h,
                  backgroundColor: Colors.transparent,
                  borderColor: AppTheme.goldColor,
                  borderWidth: 1,
                  child: Text(
                    '取消匹配',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.goldColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}