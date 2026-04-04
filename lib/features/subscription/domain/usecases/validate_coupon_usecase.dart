import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:app_cobranca/features/subscription/domain/entities/coupon.dart';

class ValidateCouponUseCase {
  ValidateCouponUseCase(this._dataSource);

  final SubscriptionRemoteDataSource _dataSource;

  Future<Result<Coupon>> call(String code) {
    return _dataSource.validateCoupon(code);
  }
}
