import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jdonut/core/storage/session_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_providers.g.dart';

@Riverpod(keepAlive: true)
SessionStore sessionStore(Ref ref) =>
    const SecureSessionStore(FlutterSecureStorage());
