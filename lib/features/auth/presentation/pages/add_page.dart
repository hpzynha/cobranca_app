import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/widgets/app_toast.dart';
import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:app_cobranca/core/theme/app_spacing.dart';
import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class AddPage extends ConsumerStatefulWidget {
  const AddPage({super.key});

  @override
  ConsumerState<AddPage> createState() => _AddPageState();
}

class _AddPageState extends ConsumerState<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _whatsappCompleteNumber = '';
  final _monthlyFeeController = TextEditingController();
  final _dueDayController = TextEditingController(text: '10');
  final _nextDueDateController = TextEditingController();
  final _lastPaymentDateController = TextEditingController();
  DateTime? _nextDueDate;
  DateTime? _lastPaymentDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _monthlyFeeController.dispose();
    _dueDayController.dispose();
    _nextDueDateController.dispose();
    _lastPaymentDateController.dispose();
    super.dispose();
  }

  int? _parseMonthlyFeeToCents(String rawValue) {
    final sanitized =
        rawValue
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

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  Future<void> _pickDate({required bool isNextDueDate}) async {
    final now = DateTime.now();
    final initialDate =
        isNextDueDate
            ? (_nextDueDate ?? now)
            : (_lastPaymentDate ?? _nextDueDate ?? now);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (isNextDueDate) {
        _nextDueDate = DateTime(selected.year, selected.month, selected.day);
        _nextDueDateController.text = _formatDate(_nextDueDate!);
        _dueDayController.text = _nextDueDate!.day.toString().padLeft(2, '0');
      } else {
        _lastPaymentDate = DateTime(
          selected.year,
          selected.month,
          selected.day,
        );
        _lastPaymentDateController.text = _formatDate(_lastPaymentDate!);
      }
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final cents = _parseMonthlyFeeToCents(_monthlyFeeController.text);
    final dueDay = int.tryParse(_dueDayController.text.trim());
    final nextDueDate = _nextDueDate;

    if (cents == null ||
        dueDay == null ||
        dueDay < 1 ||
        dueDay > 31 ||
        nextDueDate == null) {
      AppToast.warning(context, 'Revise os dados antes de cadastrar.');
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await ref
        .read(registerStudentUseCaseProvider)
        .call(
          StudentRegistrationInput(
            name: _nameController.text.trim(),
            whatsapp: _whatsappCompleteNumber.trim(),
            monthlyFeeCents: cents,
            dueDay: dueDay,
            nextDueDate: nextDueDate,
            lastPaymentDate: _lastPaymentDate,
            photoUrl: null,
          ),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!result.isSuccess) {
      if (result.failure?.code == 'plan_limit') {
        context.push('/paywall');
        return;
      }
      AppToast.error(context, result.failure?.message ?? 'Erro ao cadastrar aluno.');
      return;
    }

    AppToast.success(context, 'Aluno cadastrado com sucesso.');
    ref.invalidate(studentsProvider);
    ref.invalidate(studentPaymentItemsProvider);
    ref.invalidate(monthlyReportProvider);

    _formKey.currentState?.reset();
    _nameController.clear();
    _whatsappCompleteNumber = '';
    _monthlyFeeController.clear();
    _dueDayController.text = '10';
    _nextDueDate = null;
    _lastPaymentDate = null;
    _nextDueDateController.clear();
    _lastPaymentDateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isCompact = AppResponsive.isCompact(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = AppResponsive.size(
      context,
      isCompact ? 14 : 16,
    ).clamp(12.0, 22.0);
    final titleSize = AppResponsive.fontSize(context, isCompact ? 24 : 28);
    final subtitleSize = AppResponsive.fontSize(context, 14);
    final sectionGap = AppResponsive.size(context, isCompact ? 18 : 22);
    final pageBackground = isDark ? AppColors.backgroundDark : const Color(0xFFF3F4F6);
    final fieldBackground = isDark ? const Color(0xFF1A1A28) : const Color(0xFFF3F4F6);
    final fieldBorder = isDark ? const Color(0xFF2a2a45) : const Color(0xFFD9DCE3);
    final focusedBorderColor = isDark ? AppColors.primary : const Color(0xFFC9CED8);
    final muted = isDark ? AppColors.textMutedDark : const Color(0xFF6B7280);
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
                  borderSide: BorderSide(color: fieldBorder, width: 1.6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: fieldBorder, width: 1.6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: focusedBorderColor, width: 1.8),
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
                      onTap: () => context.go('/home'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
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
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
                      if (name.length > 100) return 'Nome muito longo';
                      return null;
                    },
                  ),
                  SizedBox(height: sectionGap - 2),
                  _FormLabel(text: 'WhatsApp *'),
                  const SizedBox(height: 8),
                  IntlPhoneField(
                    initialCountryCode: 'BR',
                    showCountryFlag: true,
                    showDropdownIcon: true,
                    dropdownIconPosition: IconPosition.trailing,
                    dropdownIcon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: muted,
                    ),
                    flagsButtonPadding: const EdgeInsets.only(left: 12, right: 8),
                    disableLengthCheck: false,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '11 99999-9999',
                    ),
                    invalidNumberMessage: 'Informe um WhatsApp válido',
                    onChanged: (phone) {
                      _whatsappCompleteNumber = phone.completeNumber;
                    },
                    onSaved: (phone) {
                      _whatsappCompleteNumber = phone?.completeNumber ?? '';
                    },
                    validator: (phone) {
                      final completeNumber =
                          phone?.completeNumber.trim() ??
                          _whatsappCompleteNumber.trim();
                      final digits = completeNumber.replaceAll(RegExp(r'\D'), '');
                      if (!completeNumber.startsWith('+') || digits.length < 10) {
                        return 'Informe um WhatsApp válido com código do país';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque na bandeira/código para trocar o país (padrão: +55).',
                    style: TextStyle(
                      fontSize: AppResponsive.fontSize(context, 12),
                      color: muted,
                    ),
                  ),
                  SizedBox(height: sectionGap - 2),
                  _FormLabel(text: 'Valor da mensalidade *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _monthlyFeeController,
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9., ]')),
                    ],
                    decoration: const InputDecoration(hintText: 'R\$ 150,00'),
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
                  SizedBox(height: sectionGap - 2),
                  _FormLabel(text: 'Próximo vencimento *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nextDueDateController,
                    readOnly: true,
                    onTap: () => _pickDate(isNextDueDate: true),
                    decoration: const InputDecoration(
                      hintText: 'Selecione a data',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    validator: (value) {
                      if (_nextDueDate == null) {
                        return 'Selecione a data do próximo vencimento';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: sectionGap - 2),
                  _FormLabel(text: 'Último pagamento (opcional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _lastPaymentDateController,
                    readOnly: true,
                    onTap: () => _pickDate(isNextDueDate: false),
                    decoration: InputDecoration(
                      hintText: 'Selecione a data',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_lastPaymentDate != null)
                            IconButton(
                              tooltip: 'Limpar data',
                              onPressed: () {
                                setState(() {
                                  _lastPaymentDate = null;
                                  _lastPaymentDateController.clear();
                                });
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                          const Icon(Icons.calendar_today_outlined),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: sectionGap),
                  SizedBox(
                    height: AppResponsive.size(context, 52).clamp(48.0, 56.0),
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child:
                          _isSubmitting
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
      bottomNavigationBar: const BottomBar(currentIndex: -1),
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: AppResponsive.fontSize(context, 16),
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : const Color(0xFF202327),
      ),
    );
  }
}
