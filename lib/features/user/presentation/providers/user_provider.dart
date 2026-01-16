import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_user_by_id.dart';
import '../../../../core/utils/dependency_injection.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return DependencyInjection.userRepository;
});

final getUserByIdProvider = Provider<GetUserById>((ref) {
  return GetUserById(ref.read(userRepositoryProvider));
});
