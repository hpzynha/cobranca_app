import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:flutter/material.dart';

class AuthOptionsRow extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onRememberChanged;
  final VoidCallback? onForgotPressed;
  final String rememberText;
  final String forgotText;

  const AuthOptionsRow({
    super.key,
    this.initialValue = false,
    this.onRememberChanged,
    this.onForgotPressed,
    this.rememberText = "Lembrar-me",
    this.forgotText = "Esqueceu sua senha?",
  });

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
    final rememberSize = AppResponsive.fontSize(
      context,
      14,
      min: 0.95,
      max: 1.08,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _remember,
              onChanged: (value) {
                setState(() {
                  _remember = value ?? false;
                });
                widget.onRememberChanged?.call(_remember);
              },
            ),
            Text(
              widget.rememberText,
              style: TextStyle(
                fontSize: rememberSize,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: widget.onForgotPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            "Esqueceu sua senha?",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
