import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_theme.dart';
import '../../core/services/audio_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/user_info_card.dart';
import '../../widgets/daily_tasks_card.dart';
import '../../widgets/quick_match_card.dart';
import '../../controllers/user_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;
  
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 为每个卡片创建交错动画
    _cardAnimations = List.generate(6, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          0.6 + index * 0.1,
          curve: Curves.easeOutBack,
        ),
      ));
    });
  }

  void _startAnimations() {
    _animationController.forward();
  }

  void _loadUserData() {
    // 加载用户数据
    ref.read(userControllerProvider.notifier).loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.gameBackgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.goldColor,
            backgroundColor: AppTheme.cardColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部导航栏
                  _buildTopBar(),
                  
                  SizedBox(height: 20.h),
                  
                  // 用户信息卡片
                  AnimatedBuilder(
                    animation: _cardAnimations[0],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _cardAnimations[0].value,
                        child: UserInfoCard(
                          user: userState.user,
                          onTap: () {
                            AudioService().playButtonClick();
                            context.push('/profile');
                          },
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // 快速匹配卡片
                  AnimatedBuilder(
                    animation: _cardAnimations[1],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _cardAnimations[1].value,
                        child: QuickMatchCard(
                          onQuickMatch: _handleQuickMatch,
                          onCreateRoom: _handleCreateRoom,
                          onJoinRoom: _handleJoinRoom,
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // 每日任务卡片
                  AnimatedBuilder(
                    animation: _cardAnimations[2],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _cardAnimations[2].value,
                        child: const DailyTasksCard(),
                      );
                    },
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // 功能网格
                  _buildFeatureGrid(),
                  
                  SizedBox(height: 20.h),
                  
                  // 最新动态
                  _buildNewsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 游戏Logo和标题
        Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.goldColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.extension,
                size: 24.sp,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              '斗地主',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldColor,
              ),
            ),
          ],
        ),
        
        // 功能按钮
        Row(
          children: [
            // 消息按钮
            IconButton(
              onPressed: () {
                AudioService().playButtonClick();
                // TODO: 实现消息功能
              },
              icon: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 24.sp,
                    color: AppTheme.goldColor,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 设置按钮
            IconButton(
              onPressed: () {
                AudioService().playButtonClick();
                _showSettingsDialog();
              },
              icon: Icon(
                Icons.settings_outlined,
                size: 24.sp,
                color: AppTheme.goldColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'icon': Icons.store, 'title': '商城', 'route': '/shop'},
      {'icon': Icons.leaderboard, 'title': '排行榜', 'route': '/leaderboard'},
      {'icon': Icons.emoji_events, 'title': '锦标赛', 'route': '/tournament'},
      {'icon': Icons.history, 'title': '游戏记录', 'route': '/history'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.w,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return AnimatedBuilder(
          animation: _cardAnimations[index + 3],
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimations[index + 3].value,
              child: _buildFeatureCard(
                icon: feature['icon'] as IconData,
                title: feature['title'] as String,
                onTap: () {
                  AudioService().playButtonClick();
                  context.push(feature['route'] as String);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.goldColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: AppTheme.goldColor,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.goldColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '游戏公告',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.goldColor,
            ),
          ),
          SizedBox(height: 12.h),
          _buildNewsItem(
            title: '每日签到奖励翻倍活动',
            content: '活动期间，每日签到奖励翻倍，不要错过哦！',
            time: '2小时前',
          ),
          SizedBox(height: 8.h),
          _buildNewsItem(
            title: '新玩法"抢地主"模式上线',
            content: '全新的游戏模式，更加刺激的对战体验。',
            time: '1天前',
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem({
    required String title,
    required String content,
    required String time,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          time,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Future<void> _handleQuickMatch() async {
    AudioService().playButtonClick();
    context.push('/game-lobby');
  }

  Future<void> _handleCreateRoom() async {
    AudioService().playButtonClick();
    // TODO: 实现创建房间功能
    _showComingSoonDialog('创建房间');
  }

  Future<void> _handleJoinRoom() async {
    AudioService().playButtonClick();
    // TODO: 实现加入房间功能
    _showComingSoonDialog('加入房间');
  }

  Future<void> _refreshData() async {
    // 刷新用户数据
    await ref.read(userControllerProvider.notifier).loadUserData();
    
    // 重新播放动画
    _animationController.reset();
    _animationController.forward();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          '游戏设置',
          style: TextStyle(
            color: AppTheme.goldColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note, color: AppTheme.goldColor),
              title: const Text('音乐设置', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现音乐设置
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_up, color: AppTheme.goldColor),
              title: const Text('音效设置', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现音效设置
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.goldColor),
              title: const Text('语言设置', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现语言设置
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '关闭',
              style: TextStyle(
                color: AppTheme.goldColor,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          '敬请期待',
          style: TextStyle(
            color: AppTheme.goldColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '$feature功能正在开发中，敬请期待！',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '确定',
              style: TextStyle(
                color: AppTheme.goldColor,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}