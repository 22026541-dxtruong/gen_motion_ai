import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/local/storage/secure_storage.dart';

class AuthNotifier extends AsyncNotifier<bool> {
  late final SecureStorage _storage;

  @override
  Future<bool> build() async {
    _storage = ref.watch(secureStorageProvider);
    return _storage.isAuthenticated();
  }

  Future<void> login(String token) async {
    await _storage.saveAccessToken(token);
    state = const AsyncData(true);
  }

  Future<void> logout() async {
    await _storage.deleteAccessToken();
    state = const AsyncData(false);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);
