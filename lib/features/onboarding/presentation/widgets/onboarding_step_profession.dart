import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingStepHowItWorks extends StatelessWidget {
  const OnboardingStepHowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFFAEEDA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              size: 52,
              color: AppColors.action,
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            'Como funciona',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 28),
          _Step(
            icon: Icons.person_add_rounded,
            color: AppColors.primary,
            title: '1. Cadastre seus alunos',
            subtitle: 'Nome, WhatsApp e dia do vencimento.',
          ),
          const SizedBox(height: 20),
          _Step(
            icon: Icons.send_rounded,
            color: AppColors.action,
            title: '2. Mensalify cobra por você',
            subtitle: 'Enviamos a mensagem no dia certo, com o tom certo.',
          ),
          const SizedBox(height: 20),
          _Step(
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            title: '3. Você só recebe',
            subtitle: 'Acompanhe quem pagou direto no painel.',
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
