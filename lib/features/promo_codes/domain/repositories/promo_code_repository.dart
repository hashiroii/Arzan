import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promo_code.dart';

enum SortOption {
  publishTime,
  expirationDate,
  alphabetical,
  mostUpvoted,
  mostRecent,
}

abstract class PromoCodeRepository {
  Future<Either<Failure, List<PromoCode>>> getPromoCodes({
    String? serviceFilter,
    SortOption sortOption = SortOption.mostRecent,
    int limit = 20,
    String? lastDocumentId,
  });

  Future<Either<Failure, PromoCode>> getPromoCodeById(String id);

  Future<Either<Failure, PromoCode>> createPromoCode(PromoCode promoCode);

  Future<Either<Failure, void>> upvotePromoCode(String promoCodeId, String userId);

  Future<Either<Failure, void>> downvotePromoCode(String promoCodeId, String userId);

  Future<Either<Failure, void>> removeVote(String promoCodeId, String userId);

  Future<Either<Failure, List<PromoCode>>> getUserPromoCodes(String userId);

  Future<Either<Failure, void>> deletePromoCode(String promoCodeId, String userId);
}
