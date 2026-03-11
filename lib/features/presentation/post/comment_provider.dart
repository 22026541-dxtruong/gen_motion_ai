import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/comment/dto/comment.dto.dart';

final commentProvider =
    AsyncNotifierProvider.family<CommentNotifier, List<CommentDto>, String>(
      CommentNotifier.new,
    );

class CommentNotifier extends AsyncNotifier<List<CommentDto>> {
  final String postId;
  CommentNotifier(this.postId);

  @override
  Future<List<CommentDto>> build() async {
    final api = ref.read(commentApiProvider);

    try {
      return await api.getComments(postId, null, 20).then((res) => res.data);
    } catch (_) {
      return [];
    }
  }

  Future<void> refresh() async {
    final api = ref.read(commentApiProvider);

    state = const AsyncLoading();

    final comment = await api.getComments(postId, null, 20).then((res) => res.data);

    state = AsyncData(comment);
  }
}
