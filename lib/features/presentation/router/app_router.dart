import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/features/presentation/create_screen.dart';
import 'package:gen_motion_ai/features/presentation/explore_screen.dart';
import 'package:gen_motion_ai/features/presentation/home/home_screen.dart';
import 'package:gen_motion_ai/shared/widgets/main_layout.dart';
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
              child: const CreateScreen(),
            ),
          ),
          GoRoute(
            path: '/explore',
            name: 'explore',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ExploreScreen(),
            ),
          ),
          // GoRoute(
          //   path: '/gallery',
          //   name: 'gallery',
          //   pageBuilder: (context, state) => NoTransitionPage(
          //     child: const GalleryScreen(),
          //   ),
          // ),
          // GoRoute(
          //   path: '/queue',
          //   name: 'queue',
          //   pageBuilder: (context, state) => NoTransitionPage(
          //     child: const QueueScreen(),
          //   ),
          // ),
        ],
      ),
    ],
  );
});