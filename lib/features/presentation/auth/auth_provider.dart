import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/local/storage/secure_storage.dart';
import 'package:gen_motion_ai/features/presentation/user/user_provider.dart';
import 'package:gen_motion_ai/main.dart';

class AuthNotifier extends AsyncNotifier<bool> {
  late final SecureStorage _storage;

  @override
  Future<bool> build() async {
    _storage = ref.watch(secureStorageProvider);

    final isAuth = await _storage.isAuthenticated();

    if (isAuth) {
      await ref.read(currentUserProvider.notifier).fetchMe();
    }

    return isAuth;
  }

  Future<void> login(String token) async {
    await _storage.saveAccessToken(token);

    await ref.read(currentUserProvider.notifier).fetchMe();

    state = const AsyncData(true);
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await _storage.deleteAccessToken();
    ref.read(currentUserProvider.notifier).logout();
    ref.read(appResetProvider.notifier).reset();
    state = const AsyncData(false);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);
