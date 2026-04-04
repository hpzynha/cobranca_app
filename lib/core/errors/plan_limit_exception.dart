class PlanLimitException implements Exception {
  const PlanLimitException([this.message = 'Limite do plano gratuito atingido.']);

  final String message;

  @override
  String toString() => 'PlanLimitException: $message';
}
