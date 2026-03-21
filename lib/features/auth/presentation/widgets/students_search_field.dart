import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:flutter/material.dart';

class StudentsSearchField extends StatelessWidget {
  const StudentsSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Buscar aluno...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final iconSize = AppResponsive.size(context, 20).clamp(18.0, 22.0);
    final fontSize = AppResponsive.fontSize(context, 14).clamp(13.0, 16.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fillColor = isDark ? AppColors.surfaceDark : const Color(0xFFF8F8F8);
    final borderColor =
        isDark ? AppColors.borderDark : const Color(0xFFE9EAED);
    final focusBorderColor =
        isDark ? AppColors.borderDark.withValues(alpha: 0.6) : const Color(0xFFD2D4D9);
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: TextStyle(fontSize: fontSize, color: textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: fontSize, color: AppColors.textMuted),
        prefixIcon:
            Icon(Icons.search_rounded, color: AppColors.textMuted, size: iconSize),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: focusBorderColor),
        ),
      ),
    );
  }
}
