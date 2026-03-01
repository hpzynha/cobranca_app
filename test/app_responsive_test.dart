import 'package:app_cobranca/core/theme/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _responsiveHarness({
  required double width,
  required Widget Function(BuildContext context) builder,
}) {
  return MediaQuery(
    data: MediaQueryData(size: Size(width, 800)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(builder: builder),
    ),
  );
}

void main() {
  group('AppResponsive', () {
    testWidgets('isCompact e isSmall refletem largura da tela', (tester) async {
      late bool isCompact;
      late bool isSmall;

      await tester.pumpWidget(
        _responsiveHarness(
          width: 350,
          builder: (context) {
            isCompact = AppResponsive.isCompact(context);
            isSmall = AppResponsive.isSmall(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(isCompact, isTrue);
      expect(isSmall, isTrue);
    });

    testWidgets('scale respeita limites mínimo e máximo', (tester) async {
      late double lowScale;
      late double highScale;

      await tester.pumpWidget(
        _responsiveHarness(
          width: 300,
          builder: (context) {
            lowScale = AppResponsive.scale(context);
            return const SizedBox.shrink();
          },
        ),
      );

      await tester.pumpWidget(
        _responsiveHarness(
          width: 500,
          builder: (context) {
            highScale = AppResponsive.scale(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(lowScale, 0.86);
      expect(highScale, 1.08);
    });

    testWidgets('size e fontSize aplicam escala esperada', (tester) async {
      late double scaledSize;
      late double scaledFontSize;

      await tester.pumpWidget(
        _responsiveHarness(
          width: 390,
          builder: (context) {
            scaledSize = AppResponsive.size(context, 20);
            scaledFontSize = AppResponsive.fontSize(context, 16);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(scaledSize, 20);
      expect(scaledFontSize, 16);
    });
  });
}
