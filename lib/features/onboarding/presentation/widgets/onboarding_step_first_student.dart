import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingStepReady extends StatelessWidget {
  const OnboardingStepReady({super.key});

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
              color: AppColors.successSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              size: 52,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            'Tudo pronto! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Agora é só cadastrar seu primeiro aluno\ne deixar o Mensalify trabalhar por você.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textMuted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 32),
          _HintCard(
            icon: Icons.add_circle_rounded,
            color: AppColors.primary,
            text: 'Toque em "+" na tela principal para adicionar um aluno',
          ),
          const SizedBox(height: 12),
          _HintCard(
            icon: Icons.bar_chart_rounded,
            color: AppColors.action,
            text: 'Acompanhe cobranças e pagamentos no painel',
          ),
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
