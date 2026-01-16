import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promo_code.dart';
import '../repositories/promo_code_repository.dart';

class GetPromoCodeById {
  final PromoCodeRepository repository;

  GetPromoCodeById(this.repository);

  Future<Either<Failure, PromoCode>> call(String id) {
    return repository.getPromoCodeById(id);
  }
}
