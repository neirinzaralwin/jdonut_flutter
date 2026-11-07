import 'package:jdonut/core/database/database_provider.dart';
import 'package:jdonut/core/storage/storage_providers.dart';
import 'package:jdonut/core/utils/clock.dart';
import 'package:jdonut/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:jdonut/features/auth/domain/repositories/auth_repository.dart';
import 'package:jdonut/features/auth/domain/usecases/register_user.dart';
import 'package:jdonut/features/auth/domain/usecases/verify_otp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_dependencies.g.dart';

/// Composition seam: the only place that knows the concrete auth repository.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => systemClock;

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => FakeAuthRepository(
  database: ref.watch(appDatabaseProvider),
  sessionStore: ref.watch(sessionStoreProvider),
  clock: ref.watch(clockProvider),
);

@riverpod
VerifyOtp verifyOtp(Ref ref) => VerifyOtp(ref.watch(authRepositoryProvider));

@riverpod
RegisterUser registerUser(Ref ref) =>
    RegisterUser(ref.watch(authRepositoryProvider), ref.watch(clockProvider));
