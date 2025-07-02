import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_theme.dart';
import '../../core/services/audio_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../controllers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showErrorSnackBar('请同意用户协议和隐私政策');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      AudioService().playButtonClick();

      final authController = ref.read(authControllerProvider.notifier);
      
      final success = await authController.register(
        _usernameController.text.trim(),
        _passwordController.text,
        _emailController.text.trim(),
      );

      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        _showErrorSnackBar('注册失败，请重试');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('注册出错：$e');
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService().playButtonClick();
            context.pop();
          },
        ),
        title: const Text('注册账户'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.gameBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),
                        
                        // 标题
                        _buildHeader(),
                        
                        SizedBox(height: 60.h),
                        
                        // 注册表单
                        _buildRegisterForm(),
                        
                        SizedBox(height: 30.h),
                        
                        // 用户协议
                        _buildTermsAgreement(),
                        
                        SizedBox(height: 30.h),
                        
                        // 注册按钮
                        _buildRegisterButton(),
                        
                        SizedBox(height: 30.h),
                        
                        // 登录链接
                        _buildLoginLink(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          '创建账户',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '加入斗地主大家庭',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
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
              if (value.length > 20) {
                return '用户名不能超过20个字符';
              }
              if (!RegExp(r'^[a-zA-Z0-9_\u4e00-\u9fa5]+$').hasMatch(value)) {
                return '用户名只能包含字母、数字、下划线和中文';
              }
              return null;
            },
          ),
          
          SizedBox(height: 20.h),
          
          // 邮箱输入框
          CustomTextField(
            controller: _emailController,
            labelText: '邮箱',
            hintText: '请输入邮箱地址',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入邮箱地址';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '请输入有效的邮箱地址';
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
              if (value.length > 20) {
                return '密码不能超过20个字符';
              }
              return null;
            },
          ),
          
          SizedBox(height: 20.h),
          
          // 确认密码输入框
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: '确认密码',
            hintText: '请再次输入密码',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.goldColor,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            obscureText: !_isConfirmPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请确认密码';
              }
              if (value != _passwordController.text) {
                return '两次输入的密码不一致';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAgreement() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: AppTheme.goldColor,
          checkColor: Colors.black,
        ),
        Expanded(
          child: Wrap(
            children: [
              Text(
                '我已阅读并同意',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
              ),
              GestureDetector(
                onTap: () {
                  AudioService().playButtonClick();
                  // TODO: 显示用户协议
                },
                child: Text(
                  '《用户协议》',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.goldColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                '和',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
              ),
              GestureDetector(
                onTap: () {
                  AudioService().playButtonClick();
                  // TODO: 显示隐私政策
                },
                child: Text(
                  '《隐私政策》',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.goldColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return CustomButton(
      onPressed: _isLoading ? null : _handleRegister,
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
              '立即注册',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账户？',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white70,
          ),
        ),
        TextButton(
          onPressed: () {
            AudioService().playButtonClick();
            context.pop();
          },
          child: Text(
            '立即登录',
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