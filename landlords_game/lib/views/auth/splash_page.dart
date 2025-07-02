import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/services/storage_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/themes/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _titleController;
  late Animation<double> _logoAnimation;
  late Animation<double> _titleAnimation;
  
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startInitialization();
  }

  void _initAnimations() {
    // Logo动画控制器
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 标题动画控制器
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo缩放动画
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // 标题淡入动画
    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _startInitialization() async {
    // 启动Logo动画
    _logoController.forward();
    
    // 延迟启动标题动画
    await Future.delayed(const Duration(milliseconds: 500));
    _titleController.forward();

    // 执行初始化任务
    await _performInitialization();

    // 等待动画完成
    await Future.wait([
      _logoController.forward(),
      _titleController.forward(),
    ]);

    // 延迟后跳转
    await Future.delayed(const Duration(milliseconds: 1000));
    _navigateToNextPage();
  }

  Future<void> _performInitialization() async {
    try {
      // 检查是否首次启动
      final isFirstLaunch = StorageService.isFirstLaunch();
      
      if (isFirstLaunch) {
        // 首次启动时的初始化
        await _firstLaunchSetup();
      }

      // 播放背景音乐
      AudioService().playBackgroundMusic(AudioService.mainMenuMusic);
      
      // 预加载必要的资源
      await _preloadAssets();
      
    } catch (e) {
      // 处理初始化错误
      debugPrint('初始化失败: $e');
    }
  }

  Future<void> _firstLaunchSetup() async {
    // 设置默认游戏配置
    await StorageService.saveSettings({
      'musicEnabled': true,
      'effectEnabled': true,
      'musicVolume': 0.7,
      'effectVolume': 0.8,
      'language': 'zh_CN',
      'showHints': true,
    });

    // 初始化游戏统计
    await StorageService.saveGameStats({
      'totalGames': 0,
      'winGames': 0,
      'loseGames': 0,
      'winRate': 0.0,
      'totalCoins': 1000, // 赠送初始金币
      'bestStreak': 0,
      'currentStreak': 0,
      'level': 1,
      'experience': 0,
    });

    // 标记首次启动完成
    await StorageService.setFirstLaunchCompleted();
  }

  Future<void> _preloadAssets() async {
    // 预加载关键图片资源
    final imagePaths = [
      'assets/images/cards/spades_3.png',
      'assets/images/avatars/default.png',
      'assets/images/ui/button_bg.png',
    ];

    for (final path in imagePaths) {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (e) {
        debugPrint('预加载图片失败: $path - $e');
      }
    }
  }

  void _navigateToNextPage() {
    if (!mounted) return;

    // 检查用户登录状态
    final userToken = StorageService.getUserToken();
    
    if (userToken != null && userToken.isNotEmpty) {
      // 已登录，跳转到主页
      context.go('/home');
    } else {
      // 未登录，跳转到登录页
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.gameBackgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo动画
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.extension,
                          size: 60.sp,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 40.h),

              // 游戏标题
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _titleAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          '斗地主',
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Landlords Game',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 80.h),

              // 加载动画
              SizedBox(
                width: 60.w,
                height: 60.w,
                child: Lottie.asset(
                  'assets/animations/loading.json',
                  errorBuilder: (context, error, stackTrace) {
                    return CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.goldColor,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),

              // 加载文本
              Text(
                '正在加载...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: 100.h),

              // 版本信息
              Padding(
                padding: EdgeInsets.only(bottom: 40.h),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}