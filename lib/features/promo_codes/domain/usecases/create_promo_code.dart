import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promo_code.dart';
import '../repositories/promo_code_repository.dart';

class CreatePromoCode {
  final PromoCodeRepository repository;

  CreatePromoCode(this.repository);

  Future<Either<Failure, PromoCode>> call(PromoCode promoCode) {
    return repository.createPromoCode(promoCode);
  }
}
