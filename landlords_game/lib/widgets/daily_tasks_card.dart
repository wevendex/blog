import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/themes/app_theme.dart';
import '../core/services/audio_service.dart';
import '../controllers/user_controller.dart';
import 'custom_button.dart';

class DailyTasksCard extends ConsumerWidget {
  const DailyTasksCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyTasksState = ref.watch(dailyTasksControllerProvider);
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          _buildHeader(ref),
          
          SizedBox(height: 16.h),
          
          // 任务进度
          _buildProgress(ref, dailyTasksState),
          
          SizedBox(height: 16.h),
          
          // 任务列表
          _buildTaskList(ref, dailyTasksState),
          
          SizedBox(height: 16.h),
          
          // 奖励领取按钮
          _buildRewardButton(ref, dailyTasksState),
        ],
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Row(
      children: [
        Icon(
          Icons.assignment,
          size: 24.sp,
          color: AppTheme.goldColor,
        ),
        SizedBox(width: 8.w),
        Text(
          '每日任务',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldColor,
          ),
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
            '每日',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.goldColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(WidgetRef ref, DailyTasksState state) {
    final controller = ref.read(dailyTasksControllerProvider.notifier);
    final progress = controller.getTaskProgressPercentage();
    final completedTasks = controller.getTaskProgress();
    final totalTasks = 5;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '今日进度',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
            Text(
              '$completedTasks/$totalTasks',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldColor,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        // 进度条
        Container(
          height: 8.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(WidgetRef ref, DailyTasksState state) {
    final tasks = [
      {'id': 'playGame', 'title': '完成一局游戏', 'reward': 20},
      {'id': 'winGame', 'title': '获得一次胜利', 'reward': 50},
      {'id': 'playThreeGames', 'title': '完成三局游戏', 'reward': 100},
      {'id': 'winThreeGames', 'title': '获得三次胜利', 'reward': 200},
      {'id': 'spendCoins', 'title': '消费100金币', 'reward': 150},
    ];
    
    return Column(
      children: tasks.map((task) {
        final isCompleted = state.tasks[task['id']] == true;
        return _buildTaskItem(
          title: task['title'] as String,
          reward: task['reward'] as int,
          isCompleted: isCompleted,
        );
      }).toList(),
    );
  }

  Widget _buildTaskItem({
    required String title,
    required int reward,
    required bool isCompleted,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isCompleted 
              ? AppTheme.goldColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 完成状态图标
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: isCompleted ? AppTheme.goldColor : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? AppTheme.goldColor : Colors.white54,
                width: 2,
              ),
            ),
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 12.sp,
                    color: Colors.black,
                  )
                : null,
          ),
          
          SizedBox(width: 12.w),
          
          // 任务标题
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: isCompleted ? Colors.white : Colors.white70,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          
          // 奖励
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                size: 16.sp,
                color: AppTheme.goldColor,
              ),
              SizedBox(width: 4.w),
              Text(
                '+$reward',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardButton(WidgetRef ref, DailyTasksState state) {
    final controller = ref.read(dailyTasksControllerProvider.notifier);
    final canClaimReward = controller.allTasksCompleted && !state.hasClaimedDaily;
    
    return CustomButton(
      onPressed: canClaimReward
          ? () => _claimDailyReward(ref)
          : null,
      width: double.infinity,
      height: 44.h,
      backgroundColor: canClaimReward
          ? AppTheme.goldColor
          : Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            canClaimReward ? Icons.card_giftcard : Icons.lock,
            size: 20.sp,
            color: canClaimReward ? Colors.black : Colors.white54,
          ),
          SizedBox(width: 8.w),
          Text(
            state.hasClaimedDaily
                ? '今日已领取'
                : canClaimReward
                    ? '领取每日奖励 +100金币'
                    : '完成所有任务解锁奖励',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: canClaimReward ? Colors.black : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _claimDailyReward(WidgetRef ref) async {
    try {
      AudioService().playCoin();
      
      final controller = ref.read(dailyTasksControllerProvider.notifier);
      await controller.claimDailyReward();
      
      // 显示奖励动画或提示
      _showRewardDialog(ref);
    } catch (e) {
      // 显示错误提示
      debugPrint('领取奖励失败: $e');
    }
  }

  void _showRewardDialog(WidgetRef ref) {
    // 这里可以显示奖励获得的动画或对话框
    // 由于上下文限制，这里只是一个占位符
    debugPrint('恭喜获得每日奖励！');
  }
}