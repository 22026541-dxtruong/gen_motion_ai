import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/post/dto/get_post.dto.dart';

final postProvider =
    AsyncNotifierProvider.family<PostNotifier, GetPostDto?, String>(
      PostNotifier.new,
    );

class PostNotifier extends AsyncNotifier<GetPostDto?> {
  final String postId;
  PostNotifier(this.postId);

  @override
  Future<GetPostDto?> build() async {
    final api = ref.read(postApiProvider);

    try {
      return await api.getPost(postId);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleLike() async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncLoading();

    final newLiked = !current.isLiked;

    state = AsyncData(
      current.copyWith(
        isLiked: newLiked,
        likeCount: current.likeCount + (newLiked ? 1 : -1),
      ),
    );

    try {
      if (newLiked) {
        await ref.read(postLikeApiProvider).likePost(postId);
      } else {
        await ref.read(postLikeApiProvider).unlikePost(postId);
      }
    } catch (e) {
      state = AsyncData(current);
    }
  }

  Future<void> refresh() async {
    final api = ref.read(postApiProvider);

    state = const AsyncLoading();

    final post = await api.getPost(postId);

    state = AsyncData(post);
  }
}
