import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // Thay đổi từ StatefulNavigationShell sang Widget

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          const _Sidebar(),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                const _TopBar(),

                Expanded(
                  child: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation, secondaryAnimation) {
                      return FadeThroughTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        child: child,
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<String>(location), 
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatefulWidget {
  const _Sidebar();

  @override
  State<_Sidebar> createState() => __SidebarState();
}

class __SidebarState extends State<_Sidebar> {
  bool _collapsed = false;
  bool _hoverLogo = false;
  bool _expandedDone = true;

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final width = _collapsed ? 72.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      onEnd: () {
        // Khi animation KẾT THÚC
        setState(() {
          _expandedDone = !_collapsed;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 12.0, 12.0),
            child: SizedBox(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.accentPurple],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() => _hoverLogo = true);
                      },
                      onExit: (_) {
                        setState(() => _hoverLogo = false);
                      },
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (_collapsed) {
                            setState(() {
                              _collapsed = false;
                              _expandedDone = false;
                            });
                          }
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: _hoverLogo && _collapsed
                              ? Icon(
                                  Icons.chevron_right,
                                  key: const ValueKey('chevron'),
                                  size: 20,
                                )
                              : Icon(
                                  Icons.auto_awesome,
                                  key: const ValueKey('logo'),
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (_expandedDone) ...[
                    const SizedBox(width: 12),
                    const Text(
                      'Gen Motion AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),

                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _collapsed = true;
                          _expandedDone = false;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Divider(color: AppTheme.borderColor),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  route: '/home',
                  isActive: currentRoute == '/home',
                  collapsed: !_expandedDone,
                ),
                _NavItem(
                  icon: Icons.add_circle_outline,
                  label: 'Create',
                  route: '/create',
                  isActive: currentRoute == '/create',
                  collapsed: !_expandedDone,
                ),
                _NavItem(
                  icon: Icons.explore_outlined,
                  label: 'Explore',
                  route: '/explore',
                  isActive: currentRoute == '/explore',
                  collapsed: !_expandedDone,
                ),
                _NavItem(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  route: '/gallery',
                  isActive: currentRoute == '/gallery',
                  collapsed: !_expandedDone,
                ),
                _NavItem(
                  icon: Icons.queue_outlined,
                  label: 'Queue',
                  route: '/queue',
                  isActive: currentRoute == '/queue',
                  collapsed: !_expandedDone,
                  badge: '3',
                ),
              ],
            ),
          ),

          // User section
          const Divider(color: AppTheme.borderColor),
          // Padding(
          //   padding: const EdgeInsets.all(12.0),
          //   child: Container(
          //     padding: const EdgeInsets.all(12),
          //     decoration: BoxDecoration(
          //       color: AppTheme.cardColor,
          //       borderRadius: BorderRadius.circular(8),
          //       border: Border.all(color: AppTheme.borderColor),
          //     ),
          //     child: Row(
          //       children: [
          //         CircleAvatar(
          //           radius: 16,
          //           backgroundColor: AppTheme.primaryColor,
          //           child: const Text('U', style: TextStyle(fontSize: 14)),
          //         ),
          //         const SizedBox(width: 12),
          //         Expanded(
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               const Text(
          //                 'User Name',
          //                 style: TextStyle(
          //                   fontSize: 13,
          //                   fontWeight: FontWeight.w600,
          //                 ),
          //               ),
          //               Row(
          //                 children: [
          //                   Icon(
          //                     Icons.bolt,
          //                     size: 12,
          //                     color: AppTheme.accentGreen,
          //                   ),
          //                   const SizedBox(width: 4),
          //                   const Text(
          //                     '150 credits',
          //                     style: TextStyle(
          //                       fontSize: 11,
          //                       color: AppTheme.textSecondary,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final String? badge;
  final bool collapsed;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    this.badge,
    required this.collapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final router = GoRouter.of(context);
            await Future.delayed(const Duration(milliseconds: 150));
            router.go(route);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),

                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isActive
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],

                if (!collapsed && badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: Container(
              height: 40,
              constraints: const BoxConstraints(maxWidth: 500),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search prompts, styles...',
                  hintStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Actions
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
