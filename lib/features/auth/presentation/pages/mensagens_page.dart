import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/features/auth/domain/entities/message_log.dart';
import 'package:app_cobranca/features/auth/presentation/providers/messages_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MensagensPage extends ConsumerWidget {
  const MensagensPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(messageLogsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Mensagens',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Expanded(
              child: switch (logsAsync) {
                AsyncData(:final value) => value.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: value.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _LogTile(log: value[i]),
                      ),
                AsyncLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                AsyncError() => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Não foi possível carregar as mensagens.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 2),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final MessageLog log;

  static const _templateLabels = {
    'lembrete_vencimento': 'Lembrete de vencimento',
    'lembrete_vencimento_pix': 'Lembrete de vencimento com PIX',
    'vencimento_hoje': 'Vence hoje',
    'vencimento_hoje_pix': 'Vence hoje com PIX',
    'cobranca_atrasada': 'Cobrança em atraso',
    'cobranca_atrasada_pix': 'Cobrança em atraso com PIX',
    'unknown': 'Mensagem não identificada',
  };

  String get _label => _templateLabels[log.template] ?? log.template;

  String get _formattedDate {
    final fmt = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');
    return fmt.format(log.sentAt);
  }

  @override
  Widget build(BuildContext context) {
    final isSent = log.status == 'sent';
    final statusColor = isSent ? AppColors.success : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C2E)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isSent ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: statusColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.studentName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma mensagem enviada ainda.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}
