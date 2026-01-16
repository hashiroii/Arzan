import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../firebase_options.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/promo_codes/data/datasources/promo_code_remote_data_source.dart';
import '../../features/promo_codes/data/repositories/promo_code_repository_impl.dart';
import '../../features/promo_codes/domain/repositories/promo_code_repository.dart';
import '../../features/user/data/datasources/user_remote_data_source.dart';
import '../../features/user/data/repositories/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';

class DependencyInjection {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firebaseAuth = firebase_auth.FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final googleSignIn = GoogleSignIn();

    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      firebaseAuth,
      firestore,
      googleSignIn,
    );
    final promoCodeRemoteDataSource = PromoCodeRemoteDataSourceImpl(firestore);
    final userRemoteDataSource = UserRemoteDataSourceImpl(firestore);

    authRepository = AuthRepositoryImpl(authRemoteDataSource);
    promoCodeRepository = PromoCodeRepositoryImpl(promoCodeRemoteDataSource);
    userRepository = UserRepositoryImpl(userRemoteDataSource);
  }

  static late AuthRepository authRepository;
  static late PromoCodeRepository promoCodeRepository;
  static late UserRepository userRepository;
}
