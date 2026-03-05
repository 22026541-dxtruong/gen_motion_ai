import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/auth/auth_api.dart';
import 'package:gen_motion_ai/core/data/network/dio_provider.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return AuthApi(dio);
});

// final userProvider = FutureProvider.autoDispose((ref) async {
//   final authApi = ref.watch(authApiProvider);
//   final user = await authApi.getCurrentUser();
//   return user;
// });
