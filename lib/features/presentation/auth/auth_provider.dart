import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/local/storage/secure_storage.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/features/presentation/user/user_provider.dart';

class AuthNotifier extends AsyncNotifier<bool> {
  late final SecureStorage _storage;

  @override
  Future<bool> build() async {
    _storage = ref.watch(secureStorageProvider);
    return _storage.isAuthenticated();
  }

  Future<void> login(String token) async {
    await _storage.saveAccessToken(token);

    final user = await ref.read(userApiProvider).getMe();
    ref
        .read(currentUserProvider.notifier)
        .setUser(
          CurrentUser(
            username: user.username,
            email: user.email,
            avatarUrl: user.avatarUrl,
            bio: user.bio,
          ),
        );
    state = const AsyncData(true);
  }

  Future<void> logout() async {
    await _storage.deleteAccessToken();
    ref.read(currentUserProvider.notifier).logout();
    state = const AsyncData(false);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);
