import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingStepWelcome extends StatelessWidget {
  const OnboardingStepWelcome({super.key, required this.userName});

  final String userName;

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
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Olá, $userName! 👋',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bem-vindo ao Mensalify',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chega de perder dinheiro por vergonha de cobrar.\nA gente faz isso por você.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
