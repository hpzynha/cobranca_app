import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({
    super.key,
    required this.balance,
    required this.userName,
  });

  final double balance;
  final String userName;

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  bool _balanceVisible = true;
  final _avatarKey = GlobalKey();

  String get _initials {
    final parts = widget.userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _showProfileMenu(BuildContext context) {
    final box =
        _avatarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final position = box.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDarkMode = ref.read(themeModeProvider) == ThemeMode.dark;

    showMenu<String>(
      context: context,
      color: isDark ? AppColors.bottomBarDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 12,
      position: RelativeRect.fromLTRB(
        screenSize.width - 210,
        position.dy + box.size.height + 6,
        16,
        0,
      ),
      items: [
        // ── User info ───────────────────────────────────────
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primary,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textStrong,
                    ),
                  ),
                  Text(
                    Supabase.instance.client.auth.currentUser?.email ?? '',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),

        // ── Menu items ──────────────────────────────────────
        PopupMenuItem<String>(
          value: 'profile',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: _MenuItem(
            icon: Icons.person_outline,
            label: 'Meu perfil',
            isDark: isDark,
          ),
        ),
        PopupMenuItem<String>(
          value: 'subscription',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: 18,
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Text(
                'Assinatura',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textStrong,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Pro',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Modo escuro ─────────────────────────────────────
        PopupMenuItem<String>(
          value: 'darkmode',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Row(
            children: [
              Icon(
                isDarkMode
                    ? Icons.dark_mode
                    : Icons.dark_mode_outlined,
                size: 18,
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Text(
                'Modo escuro',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textStrong,
                ),
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isDarkMode,
                  onChanged: (_) {
                    ref.read(themeModeProvider.notifier).toggle();
                    Navigator.of(context).pop();
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // ── Config ──────────────────────────────────────────
        PopupMenuItem<String>(
          value: 'config',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: _MenuItem(
            icon: Icons.settings_outlined,
            label: 'Configurações',
            isDark: isDark,
          ),
        ),
        const PopupMenuDivider(height: 1),

        // ── Sair ────────────────────────────────────────────
        PopupMenuItem<String>(
          value: 'signout',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: const _MenuItem(
            icon: Icons.logout,
            label: 'Sair da conta',
            color: AppColors.danger,
          ),
        ),
      ],
    ).then((value) async {
      if (!context.mounted) return;
      switch (value) {
        case 'profile':
          context.push('/perfil');
        case 'config':
          context.push('/config');
        case 'signout':
          await Supabase.instance.client.auth.signOut();
          if (context.mounted) context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyBg = isDark ? AppColors.backgroundDark : AppColors.background;

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: Column(
        children: [
          // ── Status bar + header content ──────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: logo esquerda | avatar direita
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'V',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppResponsive.fontSize(context, 12),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Venzza',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: AppResponsive.fontSize(context, 13),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      key: _avatarKey,
                      onTap: () => _showProfileMenu(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppResponsive.fontSize(context, 11),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Previsão de receita mensal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: AppResponsive.fontSize(context, 11),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _balanceVisible
                          ? Text(
                              currency.format(widget.balance),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppResponsive.fontSize(context, 26),
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            )
                          : Text(
                              '••••••',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppResponsive.fontSize(context, 22),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                              ),
                            ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _balanceVisible = !_balanceVisible),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          _balanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Wave transition ──────────────────────────────
          ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 20, color: bodyBg),
          ),
        ],
      ),
    );
  }
}

/// Corta um Container na forma de onda para a transição header → body.
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.75, size.height, size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper old) => false;
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
    this.isDark = false,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final c =
        color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textStrong);
    final iconC =
        color ?? (isDark ? AppColors.textMutedDark : AppColors.textMuted);

    return Row(
      children: [
        Icon(icon, size: 18, color: iconC),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 13, color: c)),
      ],
    );
  }
}
