import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.text,
    required this.logoPath,
    this.route,
    this.onPressed,
  });

  final String text;
  final String logoPath;
  final String? route;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF2a2a45) : const Color(0xFFD9DCE3);
    final bgColor = isDark ? Colors.transparent : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A1A);

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed!();
          } else if (route != null) {
            context.push(route!);
          }
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(logoPath, height: 18),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
