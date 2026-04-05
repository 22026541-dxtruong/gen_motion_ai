import 'package:gen_motion_ai/core/data/network/assets/assets_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/auth/auth_api.dart';
import 'package:gen_motion_ai/core/data/network/comment/comment_api.dart';
import 'package:gen_motion_ai/core/data/network/dio_provider.dart';
import 'package:gen_motion_ai/core/data/network/explore/explore_api.dart';
import 'package:gen_motion_ai/core/data/network/follow/follow_api.dart';
import 'package:gen_motion_ai/core/data/network/jobs/jobs_api.dart';
import 'package:gen_motion_ai/core/data/network/jobs/job_events_client.dart';
import 'package:gen_motion_ai/core/data/network/post/post_api.dart';
import 'package:gen_motion_ai/core/data/network/post_like/post_like_api.dart';
import 'package:gen_motion_ai/core/data/network/user/user_api.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return AuthApi(dio);
});

final userApiProvider = Provider<UserApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return UserApi(dio);
});

final assetsApiProvider = Provider<AssetsApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return AssetsApi(dio);
});

final jobsApiProvider = Provider<JobsApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return JobsApi(dio);
});

final jobEventsClientProvider = Provider<JobEventsClient>((ref) {
  return const JobEventsClient();
});

final postApiProvider = Provider<PostApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return PostApi(dio);
});

final commentApiProvider = Provider<CommentApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return CommentApi(dio);
});

final followApiProvider = Provider<FollowApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return FollowApi(dio);
});

final postLikeApiProvider = Provider<PostLikeApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return PostLikeApi(dio);
});

final exploreApiProvider = Provider<ExploreApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return ExploreApi(dio);
});
