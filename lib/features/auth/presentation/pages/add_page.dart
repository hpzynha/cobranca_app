import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';
import 'package:app_cobranca/features/auth/presentation/pages/alunos_page.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddStudentPage extends ConsumerStatefulWidget {
  const AddStudentPage({super.key});

  @override
  ConsumerState<AddStudentPage> createState() => _AddPageState();
}

class _AddPageState extends ConsumerState<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _monthlyFeeController = TextEditingController();
  final _dueDayController = TextEditingController(text: '10');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _monthlyFeeController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  int? _parseMonthlyFeeToCents(String rawValue) {
    final sanitized = rawValue
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();

    final parsed = double.tryParse(sanitized);
    if (parsed == null || parsed <= 0) {
      return null;
    }

    return (parsed * 100).round();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final cents = _parseMonthlyFeeToCents(_monthlyFeeController.text);
    final dueDay = int.tryParse(_dueDayController.text.trim());

    if (cents == null || dueDay == null || dueDay < 1 || dueDay > 31) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revise os dados antes de cadastrar.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await ref.read(registerStudentUseCaseProvider).call(
          StudentRegistrationInput(
            name: _nameController.text.trim(),
            monthlyFeeCents: cents,
            dueDay: dueDay,
            photoUrl: null,
          ),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failure?.message ?? 'Erro ao cadastrar aluno.'),
        ),
      );
      return;
    }

    ref.invalidate(studentsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aluno cadastrado com sucesso.')),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const StudentsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isCompact = AppResponsive.isCompact(context);
    final horizontalPadding =
        AppResponsive.size(context, isCompact ? 14 : 16).clamp(12.0, 22.0);
    final titleSize = AppResponsive.fontSize(context, isCompact ? 24 : 28);
    final subtitleSize = AppResponsive.fontSize(context, 14);
    final sectionGap = AppResponsive.size(context, isCompact ? 18 : 22);
    const pageBackground = Color(0xFFF3F4F6);
    const fieldBackground = Color(0xFFF3F4F6);
    const fieldBorder = Color(0xFFD9DCE3);
    const muted = Color(0xFF6B7280);
    final bottomScrollPadding =
        (isCompact ? 128.0 : 140.0) +
        mediaQuery.padding.bottom +
        mediaQuery.viewInsets.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: pageBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            10,
            horizontalPadding,
            bottomScrollPadding,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: fieldBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                hintStyle: TextStyle(
                  color: muted,
                  fontSize: AppResponsive.fontSize(context, 15),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: fieldBorder, width: 1.6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: fieldBorder, width: 1.6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFC9CED8), width: 1.8),
                ),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              color: muted,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Voltar',
                              style: TextStyle(
                                color: muted,
                                fontSize: AppResponsive.fontSize(context, 18),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppResponsive.size(context, 20)),
                  Text(
                    'Novo Aluno',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cadastre um aluno para gerenciar cobranças',
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: muted,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: sectionGap),
                  const _PhotoPickerPlaceholder(),
                  SizedBox(height: sectionGap),
                  _FormLabel(text: 'Nome do aluno *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Maria Silva',
                    ),
                    validator: (value) {
                      final name = value?.trim() ?? '';
                      if (name.isEmpty) return 'Informe o nome do aluno';
                      if (name.length < 3) return 'Nome muito curto';
                      return null;
                    },
                  ),
                  SizedBox(height: sectionGap - 2),
                  _FormLabel(text: 'Valor da mensalidade *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _monthlyFeeController,
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9., ]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'R\$ 150,00',
                    ),
                    validator: (value) {
                      final cents = _parseMonthlyFeeToCents(value ?? '');
                      if (cents == null) {
                        return 'Informe um valor válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: sectionGap - 2),
                  _FormLabel(text: 'Dia do vencimento *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dueDayController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: const InputDecoration(hintText: '10'),
                    validator: (value) {
                      final day = int.tryParse((value ?? '').trim());
                      if (day == null) return 'Informe o dia de vencimento';
                      if (day < 1 || day > 31) return 'Use um dia entre 1 e 31';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dia do mês em que a cobrança vence (1 a 31)',
                    style: TextStyle(
                      fontSize: AppResponsive.fontSize(context, 12),
                      color: muted,
                    ),
                  ),
                  SizedBox(height: sectionGap),
                  SizedBox(
                    height: AppResponsive.size(context, 52).clamp(48.0, 56.0),
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Cadastrar aluno',
                              style: TextStyle(
                                fontSize: AppResponsive.fontSize(context, 15),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 2),
    );
  }
}

class _PhotoPickerPlaceholder extends StatelessWidget {
  const _PhotoPickerPlaceholder();

  @override
  Widget build(BuildContext context) {
    final size = AppResponsive.size(context, 140).clamp(120.0, 160.0);
    final iconSize = AppResponsive.size(context, 34).clamp(30.0, 38.0);
    const muted = Color(0xFF6B7280);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload de foto será adicionado em breve.')),
            );
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD9DCE3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              size: iconSize,
              color: muted,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Adicionar foto (opcional)',
          style: TextStyle(
            fontSize: AppResponsive.fontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppResponsive.fontSize(context, 16),
        fontWeight: FontWeight.w700,
        color: const Color(0xFF202327),
      ),
    );
  }
}


class AddPage extends AddStudentPage {
  const AddPage({super.key});
}
