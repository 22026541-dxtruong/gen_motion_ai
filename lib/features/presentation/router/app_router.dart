import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gen_motion_ai/features/presentation/canvas/canvas_screen.dart';
import 'package:gen_motion_ai/features/presentation/detail/detail_screen.dart';
import 'package:gen_motion_ai/features/presentation/generate/generate_screen.dart';
import 'package:gen_motion_ai/features/presentation/explore/explore_screen.dart';
import 'package:gen_motion_ai/features/presentation/gallery/gallery_screen.dart';
import 'package:gen_motion_ai/features/presentation/home/home_screen.dart';
import 'package:gen_motion_ai/features/presentation/queue/queue_screen.dart';
import 'package:gen_motion_ai/features/presentation/user/user_screen.dart';
import 'package:gen_motion_ai/features/presentation/widgets/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child, location: state.uri.path);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
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

      /// ===============================
      /// FULLSCREEN ROUTES (KHÔNG SIDEBAR)
      /// ===============================
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
