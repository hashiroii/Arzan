import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../user/domain/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> signInAnonymously() async {
    try {
      final user = await remoteDataSource.signInAnonymously();
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(email, password);
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email,
        password,
        displayName,
      );
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Right(null);
    }
  }

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;
}
