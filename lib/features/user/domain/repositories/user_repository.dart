import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> getUserById(String userId);
  Future<Either<Failure, User>> updateUser(User user);
  Future<Either<Failure, void>> deleteUser(String userId);
  Future<Either<Failure, void>> updateUserKarma(String userId, int karmaChange);
  Future<Either<Failure, void>> recalculateUserKarma(String userId);
}
