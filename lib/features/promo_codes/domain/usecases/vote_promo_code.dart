import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/promo_code_repository.dart';

class UpvotePromoCode {
  final PromoCodeRepository repository;

  UpvotePromoCode(this.repository);

  Future<Either<Failure, void>> call(String promoCodeId, String userId) {
    return repository.upvotePromoCode(promoCodeId, userId);
  }
}

class DownvotePromoCode {
  final PromoCodeRepository repository;

  DownvotePromoCode(this.repository);

  Future<Either<Failure, void>> call(String promoCodeId, String userId) {
    return repository.downvotePromoCode(promoCodeId, userId);
  }
}

class RemoveVote {
  final PromoCodeRepository repository;

  RemoveVote(this.repository);

  Future<Either<Failure, void>> call(String promoCodeId, String userId) {
    return repository.removeVote(promoCodeId, userId);
  }
}
