import 'package:flutter/material.dart';

class AppTheme {
  // 主题色彩
  static const Color primaryColor = Color(0xFF1B5E20);
  static const Color accentColor = Color(0xFFFFD700);
  static const Color backgroundColor = Color(0xFF0D4A12);
  static const Color cardColor = Color(0xFF2E7D32);
  static const Color surfaceColor = Color(0xFF1B5E20);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  
  // 文字颜色
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF757575);
  
  // 游戏特定颜色
  static const Color goldColor = Color(0xFFFFD700);
  static const Color silverColor = Color(0xFFC0C0C0);
  static const Color bronzeColor = Color(0xFFCD7F32);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textPrimary,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
      ),
      
      // 卡片主题
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'GameFont',
          ),
        ),
      ),
      
      // 文本主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'GameFont',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimary,
          fontFamily: 'GameFont',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textSecondary,
          fontFamily: 'GameFont',
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: const TextStyle(color: accentColor),
        hintStyle: TextStyle(color: textHint),
      ),
      
      // 图标主题
      iconTheme: const IconThemeData(
        color: accentColor,
        size: 24,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
    );
  }
  
  // 渐变背景
  static const Gradient gameBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D4A12),
      Color(0xFF1B5E20),
      Color(0xFF2E7D32),
    ],
  );
  
  // 卡牌背景渐变
  static const Gradient cardBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1565C0),
      Color(0xFF0D47A1),
    ],
  );
  
  // 金币渐变
  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE082),
      Color(0xFFFFD700),
      Color(0xFFFFB300),
    ],
  );
}