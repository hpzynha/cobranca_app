class AppStrings {
  AppStrings._();

  static const dashboardTitle = 'Dashboard';
  static const monthlyForecastBalance = 'Saldo previsto do mês';

  static const statusOverdue = 'Atrasados';
  static const statusDueToday = 'Vencem hoje';
  static const statusPaid = 'Pagos';

  static const navHome = 'Início';
  static const navStudents = 'Alunos';
  static const navReports = 'Relatórios';
  static const navSettings = 'Config';

  static const collectNow = 'Cobrar agora';

  static String overdueChargesMessage(int overdueCount) {
    return 'Você tem $overdueCount cobranças vencidas';
  }
}
