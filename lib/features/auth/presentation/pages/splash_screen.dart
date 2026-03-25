import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _nameController;
  late final AnimationController _taglineController;
  late final AnimationController _barController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _nameOffset;
  late final Animation<double> _nameOpacity;
  late final Animation<Offset> _taglineOffset;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _barWidth;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _nameOffset = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _nameController, curve: Curves.easeOut));
    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _nameController, curve: Curves.easeOut),
    );

    _taglineOffset = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    _barWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeOut),
    );

    _pulseOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 50),
    ]).animate(_pulseController);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    _nameController.forward();

    await Future.delayed(const Duration(milliseconds: 150));
    _taglineController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _barController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    _pulseController.repeat();

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _nameController.dispose();
    _taglineController.dispose();
    _barController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.primary;
    final nameColor =
        isDark ? AppColors.textPrimaryDark : Colors.white;
    final taglineColor = isDark
        ? const Color(0xFF4a4a62)
        : Colors.white.withValues(alpha: 0.65);
    final barTrackColor = isDark
        ? AppColors.surfaceDark
        : Colors.white.withValues(alpha: 0.15);
    final barFillColor =
        isDark ? AppColors.primary : Colors.white.withValues(alpha: 0.7);
    final versionColor = isDark
        ? const Color(0xFF2a2a45)
        : Colors.white.withValues(alpha: 0.35);
    final decoColor = isDark
        ? AppColors.primary.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: _DecorativeCircle(size: 280, color: decoColor),
          ),
          Positioned(
            bottom: -30,
            left: -40,
            child: _DecorativeCircle(size: 190, color: decoColor),
          ),
          Positioned(
            bottom: 120,
            right: 30,
            child: _DecorativeCircle(size: 110, color: decoColor),
          ),
          Positioned(
            top: 130,
            left: 40,
            child: _DecorativeCircle(size: 65, color: decoColor),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo box
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/mensalify_icon_appstore_1024.png',
                    width: 80,
                    height: 80,
                  ),
                ),

                const SizedBox(height: 20),

                // App name
                SlideTransition(
                  position: _nameOffset,
                  child: FadeTransition(
                    opacity: _nameOpacity,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'mensal',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: nameColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'ify',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: nameColor.withValues(alpha: 0.7),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                SlideTransition(
                  position: _taglineOffset,
                  child: FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      'Automatize suas cobranças',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: taglineColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading bar
          Positioned(
            bottom: 72,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 120,
                height: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Stack(
                    children: [
                      Container(color: barTrackColor),
                      AnimatedBuilder(
                        animation: _barWidth,
                        builder: (context, _) => FractionallySizedBox(
                          widthFactor: _barWidth.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: barFillColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Version
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) => Opacity(
                opacity: _pulseController.isAnimating
                    ? _pulseOpacity.value
                    : 1.0,
                child: child,
              ),
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: versionColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
