import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/themes/app_theme.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<LeaderboardEntry> _weeklyLeaderboard = [
    LeaderboardEntry(rank: 1, name: '斗地主大师', score: 2850, avatar: '👑'),
    LeaderboardEntry(rank: 2, name: '卡牌之王', score: 2680, avatar: '🎯'),
    LeaderboardEntry(rank: 3, name: '黄金玩家', score: 2540, avatar: '⭐'),
    LeaderboardEntry(rank: 4, name: '白银高手', score: 2380, avatar: '🔥'),
    LeaderboardEntry(rank: 5, name: '青铜专家', score: 2250, avatar: '💎'),
    LeaderboardEntry(rank: 6, name: '新手村长', score: 2120, avatar: '🚀'),
    LeaderboardEntry(rank: 7, name: '幸运玩家', score: 2000, avatar: '🍀'),
    LeaderboardEntry(rank: 8, name: '稳定发挥', score: 1890, avatar: '⚡'),
    LeaderboardEntry(rank: 9, name: '潜力新星', score: 1780, avatar: '🌟'),
    LeaderboardEntry(rank: 10, name: '努力奋斗', score: 1650, avatar: '💪'),
  ];

  final List<LeaderboardEntry> _monthlyLeaderboard = [
    LeaderboardEntry(rank: 1, name: '月度冠军', score: 8650, avatar: '🏆'),
    LeaderboardEntry(rank: 2, name: '常胜将军', score: 8200, avatar: '⚔️'),
    LeaderboardEntry(rank: 3, name: '智慧之星', score: 7890, avatar: '🧠'),
    LeaderboardEntry(rank: 4, name: '策略大师', score: 7650, avatar: '📈'),
    LeaderboardEntry(rank: 5, name: '运气之神', score: 7420, avatar: '🎲'),
  ];

  final List<LeaderboardEntry> _allTimeLeaderboard = [
    LeaderboardEntry(rank: 1, name: '传奇玩家', score: 15680, avatar: '👑'),
    LeaderboardEntry(rank: 2, name: '殿堂级别', score: 14950, avatar: '🏛️'),
    LeaderboardEntry(rank: 3, name: '无敌战神', score: 14200, avatar: '⚡'),
    LeaderboardEntry(rank: 4, name: '王者归来', score: 13850, avatar: '👨‍🏫'),
    LeaderboardEntry(rank: 5, name: '巅峰时刻', score: 13500, avatar: '🔥'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('排行榜'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.goldColor,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.goldColor,
          tabs: const [
            Tab(text: '本周'),
            Tab(text: '本月'),
            Tab(text: '总榜'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 我的排名
            _buildMyRanking(),
            
            // 排行榜内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeaderboardList(_weeklyLeaderboard),
                  _buildLeaderboardList(_monthlyLeaderboard),
                  _buildLeaderboardList(_allTimeLeaderboard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRanking() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '🎮',
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的排名',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '当前排名: 第15名 | 积分: 1580',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.green,
            size: 24.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> leaderboard) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        return _buildLeaderboardItem(leaderboard[index]);
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    Color? backgroundColor;
    Color? borderColor;
    
    if (entry.rank == 1) {
      backgroundColor = const Color(0xFFFFD700).withOpacity(0.1);
      borderColor = const Color(0xFFFFD700);
    } else if (entry.rank == 2) {
      backgroundColor = const Color(0xFFC0C0C0).withOpacity(0.1);
      borderColor = const Color(0xFFC0C0C0);
    } else if (entry.rank == 3) {
      backgroundColor = const Color(0xFFCD7F32).withOpacity(0.1);
      borderColor = const Color(0xFFCD7F32);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : Border.all(
                color: AppTheme.goldColor.withOpacity(0.3),
                width: 1,
              ),
      ),
      child: Row(
        children: [
          // 排名
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _getRankColor(entry.rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: entry.rank <= 3 ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          
          // 头像
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.avatar,
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          
          // 用户名和积分
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '积分: ${entry.score}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // 奖励图标
          if (entry.rank <= 3)
            Icon(
              entry.rank == 1
                  ? Icons.emoji_events
                  : entry.rank == 2
                      ? Icons.military_tech
                      : Icons.workspace_premium,
              color: _getRankColor(entry.rank),
              size: 24.sp,
            ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // 金色
      case 2:
        return const Color(0xFFC0C0C0); // 银色
      case 3:
        return const Color(0xFFCD7F32); // 铜色
      default:
        return AppTheme.goldColor;
    }
  }
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int score;
  final String avatar;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatar,
  });
}