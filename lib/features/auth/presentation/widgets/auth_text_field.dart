import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor =
        isDark ? const Color(0xFF1A1A28) : const Color(0xFFF8F8FB);
    final borderColor =
        isDark ? const Color(0xFF2a2a45) : const Color(0xFFE0E2EA);
    final textColor =
        isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A1A);
    final labelColor =
        isDark ? const Color(0xFF5a5a72) : const Color(0xFF6B7280);
    const iconColor = Color(0xFF9CA3AF);

    Widget? suffix;
    if (widget.isPassword) {
      suffix = GestureDetector(
        onTap: () => setState(() => _obscure = !_obscure),
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: iconColor,
            size: 18,
          ),
        ),
      );
    } else if (widget.suffixIcon != null) {
      suffix = Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(widget.suffixIcon, color: iconColor, size: 18),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword ? _obscure : false,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          style: TextStyle(fontSize: 13, color: textColor),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
            ),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
