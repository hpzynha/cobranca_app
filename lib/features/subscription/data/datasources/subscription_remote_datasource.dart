import 'package:app_cobranca/core/errors/failure.dart';
import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/subscription/data/models/coupon_model.dart';
import 'package:app_cobranca/features/subscription/domain/entities/coupon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionRemoteDataSource {
  SubscriptionRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<Result<Coupon>> validateCoupon(String code) async {
    try {
      final response = await _client.functions.invoke(
        'validate-coupon',
        body: {'code': code.trim().toUpperCase()},
      );

      final data = response.data as Map<String, dynamic>;
      final valid = data['valid'] as bool? ?? false;

      if (!valid) {
        return Result.error(
          Failure(message: data['message'] as String? ?? 'Cupom inválido ou expirado.'),
        );
      }

      final model = CouponModel.fromEdgeFunctionResponse(data);
      return Result.success(model.toEntity(code.trim().toUpperCase()));
    } on FunctionException catch (e) {
      return Result.error(Failure(message: e.details?.toString() ?? 'Erro ao validar cupom.'));
    } catch (_) {
      return Result.error(const Failure(message: 'Sem conexão ou erro inesperado.'));
    }
  }

  Future<Result<void>> activateAdminCoupon(String code) async {
    try {
      final response = await _client.functions.invoke(
        'activate-admin-coupon',
        body: {'code': code.trim().toUpperCase()},
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        return Result.error(
          Failure(message: data['message'] as String? ?? 'Erro ao ativar cupom.'),
        );
      }

      return Result.success(null);
    } on FunctionException catch (e) {
      return Result.error(Failure(message: e.details?.toString() ?? 'Erro ao ativar cupom.'));
    } catch (_) {
      return Result.error(const Failure(message: 'Sem conexão ou erro inesperado.'));
    }
  }

  /// Cria cliente e cobrança no AbacatePay. Retorna a URL de pagamento.
  Future<Result<String>> createBilling() async {
    try {
      final response = await _client.functions.invoke('create-billing');

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        return Result.error(
          Failure(message: data['message'] as String? ?? 'Erro ao gerar cobrança.'),
        );
      }

      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        return Result.error(const Failure(message: 'Link de pagamento inválido.'));
      }

      return Result.success(url);
    } on FunctionException catch (e) {
      return Result.error(Failure(message: e.details?.toString() ?? 'Erro ao gerar cobrança.'));
    } catch (_) {
      return Result.error(const Failure(message: 'Sem conexão ou erro inesperado.'));
    }
  }
}
