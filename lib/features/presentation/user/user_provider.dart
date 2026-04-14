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
    final previous = state.asData?.value;
    if (previous == null) {
      state = const AsyncLoading();
    }

    final api = ref.read(userApiProvider);

    final dto = await api.getMe();

    state = AsyncData(dto);
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

    final currentUserId = ref.read(currentUserProvider).value?.id;
    if (userId == currentUserId) {
      await ref.read(currentUserProvider.notifier).fetchMe();
      state = AsyncData(ref.read(currentUserProvider).value);
      return;
    }

    final user = await api.getUserById(userId);

    state = AsyncData(user);
  }
}
