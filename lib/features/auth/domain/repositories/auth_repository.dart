import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../user/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInAnonymously();
  Future<Either<Failure, User>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, User>> signUpWithEmailAndPassword(String email, String password, String displayName);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
  Stream<User?> get authStateChanges;
}
