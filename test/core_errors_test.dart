import 'package:app_cobranca/core/errors/failure.dart';
import 'package:app_cobranca/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('toString inclui code e message', () {
      const failure = Failure(message: 'Credenciais inválidas', code: '401');

      expect(
        failure.toString(),
        'Failure(code: 401, message: Credenciais inválidas)',
      );
    });

    test('code é opcional', () {
      const failure = Failure(message: 'Erro genérico');

      expect(failure.code, isNull);
      expect(failure.message, 'Erro genérico');
    });
  });

  group('Result', () {
    test('success marca estado de sucesso e mantém dados', () {
      final result = Result.success<String>('ok');

      expect(result.isSuccess, isTrue);
      expect(result.data, 'ok');
      expect(result.failure, isNull);
    });

    test('success aceita data nulo', () {
      final result = Result.success<String>();

      expect(result.isSuccess, isTrue);
      expect(result.data, isNull);
      expect(result.failure, isNull);
    });

    test('error marca estado de erro e mantém failure', () {
      const failure = Failure(message: 'Falhou', code: '500');
      final result = Result.error<String>(failure);

      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
      expect(result.failure, failure);
    });
  });
}
