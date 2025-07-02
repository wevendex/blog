import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_theme.dart';
import '../../core/services/audio_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      // 播放按钮音效
      AudioService().playButtonClick();

      final authController = ref.read(authControllerProvider.notifier);
      
      final success = await authController.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // 登录成功，跳转到主页
        context.go('/home');
      } else if (mounted) {
        // 登录失败，显示错误提示
        _showErrorSnackBar('登录失败，请检查用户名和密码');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('登录出错：$e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    
    try {
      AudioService().playButtonClick();

      final authController = ref.read(authControllerProvider.notifier);
      
      final success = await authController.loginAsGuest();

      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        _showErrorSnackBar('游客登录失败');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('游客登录出错：$e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.gameBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 
                     MediaQuery.of(context).padding.top,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo和标题
                          _buildHeader(),
                          
                          SizedBox(height: 60.h),
                          
                          // 登录表单
                          _buildLoginForm(),
                          
                          SizedBox(height: 40.h),
                          
                          // 登录按钮
                          _buildLoginButton(),
                          
                          SizedBox(height: 20.h),
                          
                          // 游客登录
                          _buildGuestLoginButton(),
                          
                          SizedBox(height: 30.h),
                          
                          // 分割线
                          _buildDivider(),
                          
                          SizedBox(height: 30.h),
                          
                          // 第三方登录
                          _buildThirdPartyLogin(),
                          
                          SizedBox(height: 40.h),
                          
                          // 注册链接
                          _buildRegisterLink(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.extension,
            size: 40.sp,
            color: AppTheme.primaryColor,
          ),
        ),
        
        SizedBox(height: 20.h),
        
        // 标题
        Text(
          '欢迎回来',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldColor,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Text(
          '登录您的账户开始游戏',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 用户名输入框
          CustomTextField(
            controller: _usernameController,
            labelText: '用户名',
            hintText: '请输入用户名',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入用户名';
              }
              if (value.length < 3) {
                return '用户名至少3个字符';
              }
              return null;
            },
          ),
          
          SizedBox(height: 20.h),
          
          // 密码输入框
          CustomTextField(
            controller: _passwordController,
            labelText: '密码',
            hintText: '请输入密码',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.goldColor,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              if (value.length < 6) {
                return '密码至少6个字符';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return CustomButton(
      onPressed: _isLoading ? null : _handleLogin,
      width: double.infinity,
      height: 50.h,
      child: _isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : Text(
              '登录',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildGuestLoginButton() {
    return CustomButton(
      onPressed: _isLoading ? null : _handleGuestLogin,
      width: double.infinity,
      height: 50.h,
      backgroundColor: Colors.transparent,
      borderColor: AppTheme.goldColor,
      child: Text(
        '游客登录',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.goldColor,
        ),
      ),
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

  Widget _buildThirdPartyLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialButton(
          icon: Icons.chat,
          label: '微信',
          onPressed: () {
            AudioService().playButtonClick();
            // TODO: 实现微信登录
            _showErrorSnackBar('微信登录功能开发中');
          },
        ),
        _buildSocialButton(
          icon: Icons.phone_android,
          label: 'QQ',
          onPressed: () {
            AudioService().playButtonClick();
            // TODO: 实现QQ登录
            _showErrorSnackBar('QQ登录功能开发中');
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 100.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
        ),
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
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账户？',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white70,
          ),
        ),
        TextButton(
          onPressed: () {
            AudioService().playButtonClick();
            context.push('/register');
          },
          child: Text(
            '立即注册',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.goldColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}