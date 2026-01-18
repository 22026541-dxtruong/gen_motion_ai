import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/features/presentation/canvas/canvas_screen.dart';
import 'package:gen_motion_ai/features/presentation/generate/generate_screen.dart';
import 'package:gen_motion_ai/features/presentation/explore/explore_screen.dart';
import 'package:gen_motion_ai/features/presentation/gallery/gallery_screen.dart';
import 'package:gen_motion_ai/features/presentation/home/home_screen.dart';
import 'package:gen_motion_ai/features/presentation/queue/queue_screen.dart';
import 'package:gen_motion_ai/features/presentation/widgets/main_layout.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/create',
            name: 'create',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const GenerateScreen(),
            ),
          ),
          GoRoute(
            path: '/canvas',
            name: 'canvas',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const CanvasScreen(),
            ),
          ),
          GoRoute(
            path: '/explore',
            name: 'explore',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ExploreScreen(),
            ),
          ),
          GoRoute(
            path: '/gallery',
            name: 'gallery',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const GalleryScreen(),
            ),
          ),
          GoRoute(
            path: '/queue',
            name: 'queue',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const QueueScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});