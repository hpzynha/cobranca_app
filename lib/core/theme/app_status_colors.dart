import 'package:flutter/material.dart';

import 'app_colors.dart';

enum PaymentStatus { pago, atrasado, pendente, venceHoje }

class AppStatusColors {
  AppStatusColors._();

  static Color background(PaymentStatus s) => switch (s) {
    PaymentStatus.pago      => AppColors.successSurface,
    PaymentStatus.atrasado  => AppColors.dangerSurface,
    PaymentStatus.pendente  => AppColors.actionSurface,
    PaymentStatus.venceHoje => AppColors.actionSurface,
  };

  static Color foreground(PaymentStatus s) => switch (s) {
    PaymentStatus.pago      => AppColors.success,
    PaymentStatus.atrasado  => AppColors.danger,
    PaymentStatus.pendente  => AppColors.action,
    PaymentStatus.venceHoje => AppColors.action,
  };

  static Color borderLeft(PaymentStatus s) => foreground(s);
}
