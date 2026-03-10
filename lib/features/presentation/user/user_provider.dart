import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/user/dto/user.dto.dart';

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, UserDto?>(
      CurrentUserNotifier.new,
    );

class CurrentUserNotifier extends AsyncNotifier<UserDto?> {
  @override
  Future<UserDto?> build() async {
    return null;
  }

  Future<void> fetchMe() async {
    state = const AsyncLoading();

    final api = ref.read(userApiProvider);

    final dto = await api.getMe();

    final user = UserDto(
      id: dto.id,
      username: dto.username,
      email: dto.email,
      avatarUrl: dto.avatarUrl,
      bio: dto.bio,
    );

    state = AsyncData(user);
  }

  void logout() {
    state = const AsyncData(null);
  }
}

final userProvider =
    AsyncNotifierProvider.family<UserNotifier, UserDto?, String>(
      UserNotifier.new,
    );

class UserNotifier extends AsyncNotifier<UserDto?> {
  UserNotifier(this.userId);

  final String userId;

  @override
  Future<UserDto?> build() async {
    final api = ref.read(userApiProvider);

    try {
      if (userId == ref.read(currentUserProvider).value?.id) {
        return ref.read(currentUserProvider).value;
      }
      return await api.getUserById(userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    final api = ref.read(userApiProvider);

    final user = await api.getUserById(userId);

    state = AsyncData(user);
  }
}
