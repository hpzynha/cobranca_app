import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ToastType { success, error, info, warning }

class AppToast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: ToastType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: ToastType.error);

  static void info(BuildContext context, String message) =>
      show(context, message, type: ToastType.info);

  static void warning(BuildContext context, String message) =>
      show(context, message, type: ToastType.warning);
}

class _AppToastWidget extends StatefulWidget {
  const _AppToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_AppToastWidget> createState() => _AppToastWidgetState();
}

class _AppToastWidgetState extends State<_AppToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slide = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ToastStyle get _style {
    switch (widget.type) {
      case ToastType.success:
        return _ToastStyle(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          iconBg: AppColors.successSurface,
          accentColor: AppColors.success,
        );
      case ToastType.error:
        return _ToastStyle(
          icon: Icons.error_rounded,
          iconColor: AppColors.danger,
          iconBg: AppColors.dangerSurface,
          accentColor: AppColors.danger,
        );
      case ToastType.warning:
        return _ToastStyle(
          icon: Icons.warning_rounded,
          iconColor: AppColors.warning,
          iconBg: AppColors.warningSurface,
          accentColor: AppColors.warning,
        );
      case ToastType.info:
        return _ToastStyle(
          icon: Icons.info_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.primarySurface,
          accentColor: AppColors.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = _style;
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.10);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => FractionalTranslation(
            translation: Offset(0, _slide.value),
            child: Opacity(
              opacity: _fade.value,
              child: child,
            ),
          ),
          child: GestureDetector(
            onTap: _dismiss,
            child: Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(color: style.accentColor, width: 3.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: style.accentColor.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: style.iconBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(style.icon, color: style.iconColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                            height: 1.4,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastStyle {
  const _ToastStyle({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.accentColor,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color accentColor;
}
