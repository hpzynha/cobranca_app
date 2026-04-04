import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/subscription/data/datasources/subscription_remote_datasource.dart';

class ActivateAdminCouponUseCase {
  ActivateAdminCouponUseCase(this._dataSource);

  final SubscriptionRemoteDataSource _dataSource;

  Future<Result<void>> call(String code) {
    return _dataSource.activateAdminCoupon(code);
  }
}
