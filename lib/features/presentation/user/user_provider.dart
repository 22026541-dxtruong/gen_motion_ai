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
    try {
      final dto = await api.getMe();
      state = AsyncData(dto);
    } catch (_) {
      state = const AsyncData(null);
    }
  }

  void logout() {
    state = const AsyncData(null);
  }
}

final userProvider =
    FutureProvider.family<UserDto?, String>((ref, userId) async {
  final currentUser = ref.read(currentUserProvider).maybeWhen(
    data: (d) => d,
    orElse: () => null,
  );
  if (currentUser != null && currentUser.id == userId) {
    return currentUser;
  }
  final api = ref.read(userApiProvider);
  try {
    return await api.getUserById(userId);
  } catch (_) {
    return null;
  }
});

// Provider để lấy danh sách bài post của user và chỉ lọc những bài public
final userPublicPostsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, userId) async {
  try {
    // TODO: Thay thế userApiProvider bằng Provider API tương ứng với Posts/Gallery của bạn
    // Ví dụ: final api = ref.read(postApiProvider);
    // final posts = await api.getPostsByUserId(userId);
    
    // Chỉ lấy và hiển thị những bài post được người dùng cho phép công khai
    // return posts.where((post) => post.isPublic == true).toList();

    // Trả về mảng rỗng tạm thời để giao diện không bị lỗi cho đến khi bạn nối API thật
    return [];
  } catch (e) {
    return [];
  }
});
