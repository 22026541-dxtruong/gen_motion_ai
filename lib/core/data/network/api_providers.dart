import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/auth/auth_api.dart';
import 'package:gen_motion_ai/core/data/network/comment/comment_api.dart';
import 'package:gen_motion_ai/core/data/network/dio_provider.dart';
import 'package:gen_motion_ai/core/data/network/follow/follow_api.dart';
import 'package:gen_motion_ai/core/data/network/post/post_api.dart';
import 'package:gen_motion_ai/core/data/network/post_like/post_like_api.dart';
import 'package:gen_motion_ai/core/data/network/user/user_api.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return AuthApi(dio);
});

final userProvider = Provider<UserApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return UserApi(dio);
});

final postProvider = Provider<PostApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return PostApi(dio);
});

final commentProvider = Provider<CommentApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return CommentApi(dio);
});

final followProvider = Provider<FollowApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return FollowApi(dio);
});

final postLikeProvider = Provider<PostLikeApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return PostLikeApi(dio);
});
