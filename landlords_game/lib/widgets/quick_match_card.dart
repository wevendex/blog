import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/themes/app_theme.dart';
import '../core/services/audio_service.dart';
import 'custom_button.dart';

class QuickMatchCard extends StatefulWidget {
  final VoidCallback? onQuickMatch;
  final VoidCallback? onCreateRoom;
  final VoidCallback? onJoinRoom;

  const QuickMatchCard({
    super.key,
    this.onQuickMatch,
    this.onCreateRoom,
    this.onJoinRoom,
  });

  @override
  State<QuickMatchCard> createState() => _QuickMatchCardState();
}

class _QuickMatchCardState extends State<QuickMatchCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isMatching = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleQuickMatch() {
    if (_isMatching) return;
    
    setState(() => _isMatching = true);
    AudioService().playButtonClick();
    
    // 模拟匹配过程
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isMatching = false);
        widget.onQuickMatch?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
        children: [
          // 标题
          _buildHeader(),
          
          SizedBox(height: 20.h),
          
          // 快速匹配按钮
          _buildQuickMatchButton(),
          
          SizedBox(height: 16.h),
          
          // 分割线
          _buildDivider(),
          
          SizedBox(height: 16.h),
          
          // 其他功能按钮
          _buildOtherButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.flash_on,
            size: 24.sp,
            color: Colors.black,
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '开始游戏',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldColor,
              ),
            ),
            Text(
              '立即开始斗地主对战',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickMatchButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isMatching ? _pulseAnimation.value : 1.0,
          child: CustomButton(
            onPressed: _isMatching ? null : _handleQuickMatch,
            width: double.infinity,
            height: 56.h,
            backgroundColor: AppTheme.goldColor,
            borderRadius: 16,
            child: _isMatching
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '匹配中...',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: 24.sp,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '快速匹配',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white24,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '或',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white54,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white24,
          ),
        ),
      ],
    );
  }

  Widget _buildOtherButtons() {
    return Row(
      children: [
        // 创建房间
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_home,
            label: '创建房间',
            onPressed: widget.onCreateRoom,
          ),
        ),
        
        SizedBox(width: 12.w),
        
        // 加入房间
        Expanded(
          child: _buildActionButton(
            icon: Icons.login,
            label: '加入房间',
            onPressed: widget.onJoinRoom,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return CustomButton(
      onPressed: onPressed,
      height: 48.h,
      backgroundColor: Colors.transparent,
      borderColor: AppTheme.goldColor.withOpacity(0.5),
      borderWidth: 1,
      borderRadius: 12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: AppTheme.goldColor,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.goldColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}