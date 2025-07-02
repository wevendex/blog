import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/user_info_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('个人中心'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // 用户信息卡片
              const UserInfoCard(),
              SizedBox(height: 24.h),
              
              // 统计信息
              _buildStatsSection(),
              SizedBox(height: 24.h),
              
              // 功能菜单
              _buildMenuSection(),
              SizedBox(height: 24.h),
              
              // 退出登录按钮
              CustomButton(
                onPressed: _logout,
                backgroundColor: Colors.red,
                width: double.infinity,
                child: Text(
                  '退出登录',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
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
            '游戏统计',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('总场次', '156'),
              _buildStatItem('胜率', '68%'),
              _buildStatItem('最高连胜', '12'),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('地主胜率', '72%'),
              _buildStatItem('农民胜率', '65%'),
              _buildStatItem('总积分', '2,450'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      MenuItemData(
        icon: Icons.history,
        title: '游戏记录',
        subtitle: '查看游戏历史记录',
        onTap: _viewGameHistory,
      ),
      MenuItemData(
        icon: Icons.emoji_events,
        title: '成就系统',
        subtitle: '查看已获得的成就',
        onTap: _viewAchievements,
      ),
      MenuItemData(
        icon: Icons.group,
        title: '好友系统',
        subtitle: '管理游戏好友',
        onTap: _viewFriends,
      ),
      MenuItemData(
        icon: Icons.help_outline,
        title: '游戏帮助',
        subtitle: '学习游戏规则',
        onTap: _viewHelp,
      ),
      MenuItemData(
        icon: Icons.info_outline,
        title: '关于我们',
        subtitle: '版本信息和开发团队',
        onTap: _viewAbout,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.goldColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: menuItems.map((item) => _buildMenuItem(item)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(MenuItemData item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: AppTheme.goldColor,
        size: 24.sp,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.white70,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white54,
        size: 16.sp,
      ),
      onTap: item.onTap,
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          '设置',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.volume_up, color: AppTheme.goldColor),
              title: Text('音效设置', style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: true,
                activeColor: AppTheme.goldColor,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: AppTheme.goldColor),
              title: Text('推送通知', style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: true,
                activeColor: AppTheme.goldColor,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _viewGameHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('游戏记录功能开发中...')),
    );
  }

  void _viewAchievements() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('成就系统功能开发中...')),
    );
  }

  void _viewFriends() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('好友系统功能开发中...')),
    );
  }

  void _viewHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('游戏帮助功能开发中...')),
    );
  }

  void _viewAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          '关于我们',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '斗地主游戏',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '版本: 1.0.0',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8.h),
            Text(
              '开发团队: Flutter Game Studio',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8.h),
            Text(
              '一款经典的中国扑克游戏，支持在线对战和单机模式。',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          '退出登录',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '确定要退出登录吗？',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          CustomButton(
            onPressed: () {
              Navigator.pop(context);
              // 实际的退出登录逻辑
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            backgroundColor: Colors.red,
            height: 32.h,
            child: Text('确认退出'),
          ),
        ],
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}