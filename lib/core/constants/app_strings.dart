class AppStrings {
  AppStrings._();

  static const dashboardTitle = 'Dashboard';
  static const monthlyForecastBalance = 'Saldo previsto do mês';

  static const statusOverdue = 'Atrasados';
  static const statusDueToday = 'Vencem em breve';
  static const statusPaid = 'Pagos';

  static const navHome = 'Início';
  static const navStudents = 'Alunos';
  static const navReports = 'Relatórios';
  static const navSettings = 'Config';

  static const collectNow = 'Cobrar agora';

  static String overdueChargesMessage(int overdueCount) {
    if (overdueCount == 1) {
      return 'Você tem 1 cobrança vencida';
    }
    return 'Você tem $overdueCount cobranças vencidas';
  }
}
