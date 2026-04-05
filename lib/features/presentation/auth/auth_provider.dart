import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/local/storage/secure_storage.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/auth_response.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/logout.dto.dart';
import 'package:gen_motion_ai/features/presentation/user/user_provider.dart';
import 'package:gen_motion_ai/main.dart';

class AuthNotifier extends AsyncNotifier<bool> {
  late final SecureStorage _storage;

  @override
  Future<bool> build() async {
    _storage = ref.watch(secureStorageProvider);

    final isAuth = await _storage.isAuthenticated();
    if (!isAuth) {
      return false;
    }

    try {
      await ref.read(currentUserProvider.notifier).fetchMe();
      return true;
    } catch (_) {
      await _storage.clearAllTokens();
      ref.read(currentUserProvider.notifier).logout();
      return false;
    }
  }

  Future<void> login(AuthResponse response) async {
    await _storage.saveAccessToken(response.accessToken);
    await _storage.saveRefreshToken(response.refreshToken);

    await ref.read(currentUserProvider.notifier).fetchMe();

    state = const AsyncData(true);
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await ref
            .read(authApiProvider)
            .logout(LogoutDto(refreshToken: refreshToken));
      } catch (_) {
        debugPrint('Logout request failed, clearing local session anyway.');
      }
    }

    await _storage.clearAllTokens();
    ref.read(currentUserProvider.notifier).logout();
    ref.read(appResetProvider.notifier).reset();
    state = const AsyncData(false);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);
