import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/promo_code.dart';
import '../../domain/repositories/promo_code_repository.dart';
import '../datasources/promo_code_remote_data_source.dart';
import '../models/promo_code_model.dart';
import '../../../user/data/datasources/user_remote_data_source.dart';
import '../../../user/domain/repositories/user_repository.dart';

class PromoCodeRepositoryImpl implements PromoCodeRepository {
  final PromoCodeRemoteDataSource remoteDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final UserRepository userRepository;

  PromoCodeRepositoryImpl(
    this.remoteDataSource,
    this.userRemoteDataSource,
    this.userRepository,
  );

  @override
  Future<Either<Failure, List<PromoCode>>> getPromoCodes({
    String? serviceFilter,
    SortOption sortOption = SortOption.mostRecent,
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      final models = await remoteDataSource.getPromoCodes(
        serviceFilter: serviceFilter,
        sortOption: sortOption,
        limit: limit,
        lastDocumentId: lastDocumentId,
      );
      
      final promoCodesWithAuthors = await Future.wait(
        models.map((model) async {
          try {
            final author = await userRemoteDataSource.getUserById(model.authorId);
            return PromoCodeModel(
              id: model.id,
              code: model.code,
              serviceName: model.serviceName,
              authorId: model.authorId,
              author: author.toEntity(),
              comment: model.comment,
              publishDate: model.publishDate,
              expirationDate: model.expirationDate,
              upvotes: model.upvotes,
              downvotes: model.downvotes,
              upvotedBy: model.upvotedBy,
              downvotedBy: model.downvotedBy,
              isActive: model.isActive,
            );
          } catch (e) {
            return model;
          }
        }),
      );
      
      return Right(promoCodesWithAuthors.map((model) => model.toEntity()).toList());
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PromoCode>> getPromoCodeById(String id) async {
    try {
      final model = await remoteDataSource.getPromoCodeById(id);
      
      try {
        final author = await userRemoteDataSource.getUserById(model.authorId);
        final modelWithAuthor = PromoCodeModel(
          id: model.id,
          code: model.code,
          serviceName: model.serviceName,
          authorId: model.authorId,
          author: author.toEntity(),
          comment: model.comment,
          publishDate: model.publishDate,
          expirationDate: model.expirationDate,
          upvotes: model.upvotes,
          downvotes: model.downvotes,
          upvotedBy: model.upvotedBy,
          downvotedBy: model.downvotedBy,
          isActive: model.isActive,
        );
        return Right(modelWithAuthor.toEntity());
      } catch (e) {
        // If author fetch fails, return model without author
        return Right(model.toEntity());
      }
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PromoCode>> createPromoCode(PromoCode promoCode) async {
    try {
      final model = PromoCodeModel.fromEntity(promoCode);
      final created = await remoteDataSource.createPromoCode(model);
      return Right(created.toEntity());
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> upvotePromoCode(String promoCodeId, String userId) async {
    try {
      final currentPromoCode = await remoteDataSource.getPromoCodeById(promoCodeId);
      final authorId = currentPromoCode.authorId;
      final wasAlreadyUpvoted = currentPromoCode.upvotedBy.contains(userId);
      final wasDownvoted = currentPromoCode.downvotedBy.contains(userId);
      
      await remoteDataSource.upvotePromoCode(promoCodeId, userId);
      
      try {
        if (!wasAlreadyUpvoted) {
          final karmaResult = await userRepository.updateUserKarma(authorId, 1);
          karmaResult.fold(
            (failure) => AppLogger.error('Failed to update karma (upvote)', failure, null, 'PromoCode'),
            (_) => AppLogger.debug('Updated karma: +1 for user $authorId', 'PromoCode'),
          );
          if (wasDownvoted) {
            final karmaResult2 = await userRepository.updateUserKarma(authorId, 1);
            karmaResult2.fold(
              (failure) => AppLogger.error('Failed to update karma (remove downvote)', failure, null, 'PromoCode'),
              (_) => AppLogger.debug('Updated karma: +1 more for user $authorId', 'PromoCode'),
            );
          }
        } else {
          final karmaResult = await userRepository.updateUserKarma(authorId, -1);
          karmaResult.fold(
            (failure) => AppLogger.error('Failed to update karma (remove upvote)', failure, null, 'PromoCode'),
            (_) => AppLogger.debug('Updated karma: -1 for user $authorId', 'PromoCode'),
          );
        }
      } catch (e) {
        AppLogger.error('Error updating karma', e, null, 'PromoCode');
      }
      
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> downvotePromoCode(String promoCodeId, String userId) async {
    try {
      final currentPromoCode = await remoteDataSource.getPromoCodeById(promoCodeId);
      final authorId = currentPromoCode.authorId;
      final wasAlreadyDownvoted = currentPromoCode.downvotedBy.contains(userId);
      final wasUpvoted = currentPromoCode.upvotedBy.contains(userId);
      
      await remoteDataSource.downvotePromoCode(promoCodeId, userId);
      
      try {
        if (!wasAlreadyDownvoted) {
          final karmaResult = await userRepository.updateUserKarma(authorId, -1);
          karmaResult.fold(
            (failure) => AppLogger.error('Failed to update karma (downvote)', failure, null, 'PromoCode'),
            (_) => AppLogger.debug('Updated karma: -1 for user $authorId', 'PromoCode'),
          );
          if (wasUpvoted) {
            final karmaResult2 = await userRepository.updateUserKarma(authorId, -1);
            karmaResult2.fold(
              (failure) => AppLogger.error('Failed to update karma (remove upvote)', failure, null, 'PromoCode'),
              (_) => AppLogger.debug('Updated karma: -1 more for user $authorId', 'PromoCode'),
            );
          }
        } else {
          final karmaResult = await userRepository.updateUserKarma(authorId, 1);
          karmaResult.fold(
            (failure) => AppLogger.error('Failed to update karma (remove downvote)', failure, null, 'PromoCode'),
            (_) => AppLogger.debug('Updated karma: +1 for user $authorId', 'PromoCode'),
          );
        }
      } catch (e) {
        AppLogger.error('Error updating karma', e, null, 'PromoCode');
      }
      
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeVote(String promoCodeId, String userId) async {
    try {
      final currentPromoCode = await remoteDataSource.getPromoCodeById(promoCodeId);
      final authorId = currentPromoCode.authorId;
      final wasUpvoted = currentPromoCode.upvotedBy.contains(userId);
      final wasDownvoted = currentPromoCode.downvotedBy.contains(userId);
      
      await remoteDataSource.removeVote(promoCodeId, userId);
      
      try {
        if (wasUpvoted) {
          final karmaResult = await userRepository.updateUserKarma(authorId, -1);
          karmaResult.fold(
            (failure) => AppLogger.error('Failed to update karma (remove upvote)', failure, null, 'PromoCode'),
            (_) => AppLogger.debug('Updated karma: -1 for user $authorId', 'PromoCode'),
          );
        } else if (wasDownvoted) {
          final karmaResult = await userRepository.updateUserKarma(authorId, 1);
          karmaResult.fold(
            (failure) => AppLogger.error('Failed to update karma (remove downvote)', failure, null, 'PromoCode'),
            (_) => AppLogger.debug('Updated karma: +1 for user $authorId', 'PromoCode'),
          );
        }
      } catch (e) {
        AppLogger.error('Error updating karma', e, null, 'PromoCode');
      }
      
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PromoCode>>> getUserPromoCodes(String userId) async {
    try {
      final models = await remoteDataSource.getUserPromoCodes(userId);
      
      final promoCodesWithAuthors = await Future.wait(
        models.map((model) async {
          try {
            final author = await userRemoteDataSource.getUserById(model.authorId);
            return PromoCodeModel(
              id: model.id,
              code: model.code,
              serviceName: model.serviceName,
              authorId: model.authorId,
              author: author.toEntity(),
              comment: model.comment,
              publishDate: model.publishDate,
              expirationDate: model.expirationDate,
              upvotes: model.upvotes,
              downvotes: model.downvotes,
              upvotedBy: model.upvotedBy,
              downvotedBy: model.downvotedBy,
              isActive: model.isActive,
            );
          } catch (e) {
            return model;
          }
        }),
      );
      
      return Right(promoCodesWithAuthors.map((model) => model.toEntity()).toList());
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePromoCode(String promoCodeId, String userId) async {
    try {
      await remoteDataSource.deletePromoCode(promoCodeId, userId);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> recalculateUserKarma(String userId) async {
    try {
      final promoCodesResult = await getUserPromoCodes(userId);
      
      return promoCodesResult.fold(
        (failure) => Left(failure),
        (promoCodes) async {
          int totalKarma = 0;
          for (final promoCode in promoCodes) {
            totalKarma += (promoCode.upvotes - promoCode.downvotes);
          }
          
          try {
            await userRemoteDataSource.recalculateUserKarma(userId, totalKarma);
            AppLogger.info('Recalculated karma for user $userId: $totalKarma', 'PromoCode');
            return const Right(null);
          } catch (e) {
            return Left(ServerFailure(e.toString()));
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
