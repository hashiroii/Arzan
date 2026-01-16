import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../user/domain/entities/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DependencyInjection.authRepository;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});
