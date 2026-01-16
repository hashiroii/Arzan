import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUserById {
  final UserRepository repository;

  GetUserById(this.repository);

  Future<Either<Failure, User>> call(String userId) {
    return repository.getUserById(userId);
  }
}
