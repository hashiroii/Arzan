import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/promo_code.dart';
import '../../domain/repositories/promo_code_repository.dart';
import '../datasources/promo_code_remote_data_source.dart';
import '../models/promo_code_model.dart';

class PromoCodeRepositoryImpl implements PromoCodeRepository {
  final PromoCodeRemoteDataSource remoteDataSource;

  PromoCodeRepositoryImpl(this.remoteDataSource);

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
      return Right(models.map((model) => model.toEntity()).toList());
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
      return Right(model.toEntity());
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
      await remoteDataSource.upvotePromoCode(promoCodeId, userId);
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
      await remoteDataSource.downvotePromoCode(promoCodeId, userId);
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
      await remoteDataSource.removeVote(promoCodeId, userId);
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
      return Right(models.map((model) => model.toEntity()).toList());
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
}
