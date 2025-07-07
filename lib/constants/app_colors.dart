import 'package:flutter/material.dart';

class AppColors {
  // 主色调
  static const Color primary = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF2196F3);
  
  // 文本颜色
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF95A5A6);
  
  // 状态颜色
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF1C40F);
  
  // 渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 背景色
  static const Color background = Color(0xFFF5F6FA);
  static const Color cardBackground = Colors.white;
  
  // 边框和分割线
  static const Color border = Color(0xFFECF0F1);
  static const Color divider = Color(0xFFBDC3C7);
  
  // 阴影
  static Color shadowColor = Colors.black.withOpacity(0.1);
} 