import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/themes/app_theme.dart';
import '../core/services/audio_service.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool enableFeedback;
  final bool enableAnimation;
  final BoxShadow? shadow;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.borderRadius = 8,
    this.padding,
    this.enableFeedback = true,
    this.enableAnimation = true,
    this.shadow,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && widget.enableAnimation) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableAnimation) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableAnimation) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      // 播放按钮音效
      if (widget.enableFeedback) {
        AudioService().playButtonClick();
      }
      
      // 触觉反馈
      HapticFeedback.lightImpact();
      
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppTheme.goldColor;
    final borderColor = widget.borderColor ?? Colors.transparent;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: widget.enableAnimation
          ? AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildButton(backgroundColor, borderColor),
                );
              },
            )
          : _buildButton(backgroundColor, borderColor),
    );
  }

  Widget _buildButton(Color backgroundColor, Color borderColor) {
    final isDisabled = widget.onPressed == null;
    final finalBackgroundColor = isDisabled
        ? backgroundColor.withOpacity(0.5)
        : backgroundColor;
    
    return Container(
      width: widget.width,
      height: widget.height ?? 48.h,
      padding: widget.padding ?? EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: finalBackgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        border: widget.borderWidth > 0
            ? Border.all(
                color: borderColor,
                width: widget.borderWidth,
              )
            : null,
        boxShadow: _buildShadow(isDisabled),
        gradient: !isDisabled ? _buildGradient(backgroundColor) : null,
      ),
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            color: _getTextColor(backgroundColor, isDisabled),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          child: widget.child,
        ),
      ),
    );
  }

  List<BoxShadow>? _buildShadow(bool isDisabled) {
    if (isDisabled) return null;
    
    final baseShadow = widget.shadow ?? BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 4),
    );
    
    return widget.enableAnimation && _animationController.isAnimating
        ? [
            BoxShadow(
              color: baseShadow.color.withOpacity(
                baseShadow.color.opacity * _shadowAnimation.value,
              ),
              blurRadius: baseShadow.blurRadius * _shadowAnimation.value,
              offset: baseShadow.offset * _shadowAnimation.value,
            ),
          ]
        : [baseShadow];
  }

  Gradient? _buildGradient(Color backgroundColor) {
    // 为金色按钮添加渐变效果
    if (backgroundColor == AppTheme.goldColor) {
      return AppTheme.goldGradient;
    }
    
    return null;
  }

  Color _getTextColor(Color backgroundColor, bool isDisabled) {
    if (isDisabled) {
      return Colors.white.withOpacity(0.5);
    }
    
    // 根据背景色确定文字颜色
    if (backgroundColor == AppTheme.goldColor) {
      return Colors.black;
    } else if (backgroundColor == Colors.transparent) {
      return AppTheme.goldColor;
    } else {
      return Colors.white;
    }
  }
}

// 专门的图标按钮
class CustomIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double? iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final String? tooltip;
  final bool enableFeedback;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconSize,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.tooltip,
    this.enableFeedback = true,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      if (widget.enableFeedback) {
        AudioService().playButtonClick();
        HapticFeedback.lightImpact();
      }
      
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 48.w;
    final iconSize = widget.iconSize ?? 24.sp;
    final iconColor = widget.iconColor ?? AppTheme.goldColor;
    final backgroundColor = widget.backgroundColor ?? Colors.transparent;
    
    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: backgroundColor != Colors.transparent
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              widget.icon,
              size: iconSize,
              color: widget.onPressed != null
                  ? iconColor
                  : iconColor.withOpacity(0.5),
            ),
          ),
        );
      },
    );

    button = InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: button,
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

// 浮动操作按钮样式
class CustomFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final double? size;
  final bool enableAnimation;

  const CustomFloatingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.size,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? 56.w;
    final backgroundColor = this.backgroundColor ?? AppTheme.goldColor;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.goldGradient,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onPressed != null) {
              AudioService().playButtonClick();
              HapticFeedback.mediumImpact();
              onPressed!();
            }
          },
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(child: child),
        ),
      ),
    );
  }
}