import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthOptionsRow extends StatefulWidget {
  const AuthOptionsRow({
    super.key,
    this.initialValue = false,
    this.onRememberChanged,
    this.onForgotPressed,
    this.rememberText = 'Lembrar-me',
    this.forgotText = 'Esqueceu a senha?',
  });

  final bool initialValue;
  final ValueChanged<bool>? onRememberChanged;
  final VoidCallback? onForgotPressed;
  final String rememberText;
  final String forgotText;

  @override
  State<AuthOptionsRow> createState() => _AuthOptionsRowState();
}

class _AuthOptionsRowState extends State<AuthOptionsRow> {
  late bool _remember;

  @override
  void initState() {
    super.initState();
    _remember = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? const Color(0xFF5a5a72) : const Color(0xFF6B7280);
    final checkBorderColor =
        isDark ? const Color(0xFF2a2a45) : const Color(0xFFD9DCE3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _remember = !_remember);
            widget.onRememberChanged?.call(_remember);
          },
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _remember ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        _remember ? AppColors.primary : checkBorderColor,
                    width: 1.5,
                  ),
                ),
                child: _remember
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 7),
              Text(
                widget.rememberText,
                style: TextStyle(fontSize: 12, color: mutedColor),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: widget.onForgotPressed,
          child: Text(
            widget.forgotText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
