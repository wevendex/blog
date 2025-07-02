import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/themes/app_theme.dart';
import '../models/player_model.dart';

class UserInfoCard extends StatelessWidget {
  final PlayerModel? user;
  final VoidCallback? onTap;

  const UserInfoCard({
    super.key,
    this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return _buildLoadingCard();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor,
              AppTheme.cardColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppTheme.goldColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 头像
            _buildAvatar(),
            
            SizedBox(width: 16.w),
            
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 昵称和称号
                  _buildNameAndTitle(),
                  
                  SizedBox(height: 8.h),
                  
                  // 等级进度条
                  _buildLevelProgress(),
                  
                  SizedBox(height: 12.h),
                  
                  // 统计信息
                  _buildStats(),
                ],
              ),
            ),
            
            // 金币显示
            _buildCoinsDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 120.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.goldColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        // 头像背景光环
        Container(
          width: 70.w,
          height: 70.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.goldColor.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        
        // 头像
        Container(
          width: 64.w,
          height: 64.w,
          margin: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.goldColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.goldColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: user!.avatar.startsWith('http')
                ? Image.network(
                    user!.avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        
        // 在线状态指示器
        if (user!.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.goldGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 32.sp,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildNameAndTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 昵称
        Text(
          user!.nickname,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 2.h),
        
        // 称号
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 2.h,
          ),
          decoration: BoxDecoration(
            color: AppTheme.goldColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppTheme.goldColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            user!.titleName,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppTheme.goldColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgress() {
    final level = user!.level.level;
    final experience = user!.level.experience;
    final expToNext = user!.level.expToNext;
    final progress = experience / (experience + expToNext);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 等级标签
        Row(
          children: [
            Text(
              'Lv.$level',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldColor,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '$experience/$expToNext EXP',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 4.h),
        
        // 进度条
        Container(
          height: 6.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final stats = user!.stats;
    
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.games,
          label: '总场次',
          value: '${stats.totalGames}',
        ),
        SizedBox(width: 16.w),
        _buildStatItem(
          icon: Icons.emoji_events,
          label: '胜率',
          value: '${(stats.winRate * 100).toStringAsFixed(1)}%',
        ),
        SizedBox(width: 16.w),
        _buildStatItem(
          icon: Icons.local_fire_department,
          label: '连胜',
          value: '${stats.currentStreak}',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: AppTheme.goldColor,
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildCoinsDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            size: 20.sp,
            color: Colors.black87,
          ),
          SizedBox(width: 4.w),
          Text(
            '${user!.stats.totalCoins}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}