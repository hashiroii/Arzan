import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promo_code.dart';
import '../repositories/promo_code_repository.dart';

class GetPromoCodes {
  final PromoCodeRepository repository;

  GetPromoCodes(this.repository);

  Future<Either<Failure, List<PromoCode>>> call({
    String? serviceFilter,
    SortOption sortOption = SortOption.mostRecent,
    int limit = 20,
    String? lastDocumentId,
  }) {
    return repository.getPromoCodes(
      serviceFilter: serviceFilter,
      sortOption: sortOption,
      limit: limit,
      lastDocumentId: lastDocumentId,
    );
  }
}
