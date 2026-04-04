import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/social_auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AuthLandingScreen extends StatefulWidget {
  const AuthLandingScreen({super.key});

  @override
  State<AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends State<AuthLandingScreen> {
  final _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topColor =
        isDark ? const Color(0xFF3a2db8) : AppColors.primary;
    final bottomColor =
        isDark ? AppColors.backgroundDark : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2a2a45) : const Color(0xFFD9DCE3);
    final outlineTextColor =
        isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A1A);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: topColor,
        body: Column(
          children: [
            // ── Top (indigo) ─────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -30,
                    right: -30,
                    child: _DecoCircle(size: 160),
                  ),
                  Positioned(
                    bottom: 30,
                    left: -25,
                    child: _DecoCircle(size: 100),
                  ),
                  Positioned(
                    bottom: 70,
                    right: 20,
                    child: _DecoCircle(size: 60),
                  ),
                  // Logo content
                  Center(
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon badge
                          Image.asset(
                            'assets/images/mensalify_icon_appstore_1024.png',
                            width: 64,
                            height: 64,
                          ),
                          const SizedBox(height: 14),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'mensal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'ify',
                                  style: TextStyle(
                                    color: Color(0xB3FFFFFF),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Automatize suas cobranças\ne nunca mais perca dinheiro.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Wave transition ──────────────────────────────
            ClipPath(
              clipper: _WaveClipper(),
              child: Container(height: 28, color: bottomColor),
            ),

            // ── Bottom (white / dark) ────────────────────────
            Container(
              color: bottomColor,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Column(
                    children: [
                      // Entrar
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: () => context.push('/login'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Divider
                      _Divider(isDark: isDark),
                      const SizedBox(height: 12),

                      // Google
                      SocialAuthButton(
                        text: 'Continuar com Google',
                        logoPath: 'assets/images/google_logo.svg',
                        onPressed: () =>
                            _authController.signInWithGoogle(),
                      ),
                      const SizedBox(height: 10),

                      // Criar conta
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => context.push('/register'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: borderColor,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Criar conta',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: outlineTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecoCircle extends StatelessWidget {
  const _DecoCircle({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lineColor =
        isDark ? const Color(0xFF252535) : const Color(0xFFE8EAF0);

    return Row(
      children: [
        Expanded(child: Divider(color: lineColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor, thickness: 1)),
      ],
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.25, 0, size.width * 0.5, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.75, size.height, size.width, size.height / 2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper old) => false;
}
