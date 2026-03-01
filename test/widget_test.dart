import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTheme.useGoogleFontsForTests = false;

  test('AppTheme.lightTheme usa configurações principais esperadas', () {
    final theme = AppTheme.lightTheme;

    expect(theme.useMaterial3, isTrue);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.appBarTheme.foregroundColor, AppColors.textPrimary);
  });

  test('CheckboxTheme aplica cor primária quando selecionado', () {
    final fillColor = AppTheme.lightTheme.checkboxTheme.fillColor;

    final selectedColor = fillColor?.resolve({WidgetState.selected});
    final unselectedColor = fillColor?.resolve({});

    expect(selectedColor, AppColors.primary);
    expect(unselectedColor, Colors.transparent);
  });
}
