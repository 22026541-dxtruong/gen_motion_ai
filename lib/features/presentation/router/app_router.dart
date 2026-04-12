import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/features/presentation/auth/auth_provider.dart';
import 'package:gen_motion_ai/features/presentation/user/me_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:gen_motion_ai/features/presentation/auth/auth_screen.dart';
import 'package:gen_motion_ai/features/presentation/post/post_screen.dart';
import 'package:gen_motion_ai/features/presentation/generate/generate_screen.dart';
import 'package:gen_motion_ai/features/presentation/explore/explore_screen.dart';
import 'package:gen_motion_ai/features/presentation/gallery/gallery_screen.dart';
import 'package:gen_motion_ai/features/presentation/queue/queue_screen.dart';
import 'package:gen_motion_ai/features/presentation/user/user_screen.dart';
import 'package:gen_motion_ai/features/presentation/widgets/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/explore',
    redirect: (context, state) => auth.when(
      data: (isAuthenticated) {
        final loggingIn =
            state.uri.path == '/login' || state.uri.path == '/register';
        if (!isAuthenticated && !loggingIn) return '/login';
        if (isAuthenticated && loggingIn) return '/explore';
        return null;
      },
      loading: () => null,
      error: (e, st) => null,
    ),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AuthScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AuthScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: '/explore',
            name: 'explore',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ExploreScreen()),
          ),
          GoRoute(
            path: '/create',
            name: 'create',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: GenerateScreen()),
          ),
          GoRoute(
            path: '/gallery',
            name: 'gallery',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: GalleryScreen()),
          ),
          GoRoute(
            path: '/queue',
            name: 'queue',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: QueueScreen()),
          ),
        ],
      ),

      GoRoute(
        path: '/post/:id',
        name: 'post',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(child: PostScreen(postId: id));
        },
      ),
      GoRoute(
        path: '/user/:id',
        name: 'user',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(child: UserScreen(userId: id));
        },
      ),
      GoRoute(
        path: '/me',
        name: 'me',
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: MeScreen());
        },
      ),
    ],
  );
});
