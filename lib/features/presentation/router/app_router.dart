import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gen_motion_ai/features/presentation/auth/auth_screen.dart';
import 'package:gen_motion_ai/features/presentation/canvas/canvas_screen.dart';
import 'package:gen_motion_ai/features/presentation/detail/detail_screen.dart';
import 'package:gen_motion_ai/features/presentation/generate/generate_screen.dart';
import 'package:gen_motion_ai/features/presentation/explore/explore_screen.dart';
import 'package:gen_motion_ai/features/presentation/gallery/gallery_screen.dart';
import 'package:gen_motion_ai/features/presentation/queue/queue_screen.dart';
import 'package:gen_motion_ai/features/presentation/user/user_screen.dart';
import 'package:gen_motion_ai/features/presentation/widgets/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/explore',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => const NoTransitionPage(child: AuthScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => const NoTransitionPage(child: AuthScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child, location: state.uri.path);
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
            path: '/canvas',
            name: 'canvas',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CanvasScreen()),
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
        path: '/detail/:id',
        name: 'detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(
            child: DetailScreen(id: id),
          );
        },
      ),
      GoRoute(
        path: '/user/:id',
        name: 'user',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(
            child: UserScreen(userId: id),
          );
        },
      ),
    ],
  );
});
