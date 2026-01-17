import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class MainLayout extends StatefulWidget {
  final Widget child; // Thay đổi từ StatefulNavigationShell sang Widget

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;

    return Scaffold(
      body: Responsive(
        mobile: _buildMobileLayout(location),
        desktop: _buildDesktopLayout(location),
      ),
    );
  }

  Widget _buildMobileLayout(String location) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: _MobileTopBar(
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        Expanded(
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation, secondaryAnimation) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: KeyedSubtree(key: ValueKey(location), child: widget.child),
          ),
        ),
        const _MobileBottomNav(),
      ],
    );
  }

  Widget _buildDesktopLayout(String location) {
    return Row(
      children: [
        const _DesktopSidebar(),
        Expanded(
          child: Column(
            children: [
              const _DesktopTopBar(),
              Expanded(
                child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation, secondaryAnimation) {
                    return FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: child,
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(location),
                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopSidebar extends StatefulWidget {
  const _DesktopSidebar();

  @override
  State<_DesktopSidebar> createState() => __DesktopSidebarState();
}

class __DesktopSidebarState extends State<_DesktopSidebar> {
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
                _DesktopNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  route: '/home',
                  isActive: currentRoute == '/home',
                  collapsed: !_expandedDone,
                ),
                _DesktopNavItem(
                  icon: Icons.add_circle_outline,
                  label: 'Create',
                  route: '/create',
                  isActive: currentRoute == '/create',
                  collapsed: !_expandedDone,
                ),
                _DesktopNavItem(
                  icon: Icons.explore_outlined,
                  label: 'Explore',
                  route: '/explore',
                  isActive: currentRoute == '/explore',
                  collapsed: !_expandedDone,
                ),
                _DesktopNavItem(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  route: '/gallery',
                  isActive: currentRoute == '/gallery',
                  collapsed: !_expandedDone,
                ),
                _DesktopNavItem(
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              height: 56,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor,
                    child: const Text('U', style: TextStyle(fontSize: 14)),
                  ),
                  if (_expandedDone) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'User Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 12,
                                color: AppTheme.accentGreen,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '150 credits',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final String? badge;
  final bool collapsed;

  const _DesktopNavItem({
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

class _MobileTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const _MobileTopBar({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.menu), onPressed: onMenuTap),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentPurple],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.auto_awesome, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'Kling AI',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: SafeArea(
        child: Column(
          children: [
            // User info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor,
                    child: const Text('U', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.bolt,
                              size: 14,
                              color: AppTheme.accentGreen,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '150 credits',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppTheme.borderColor),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: const [
                  _MobileNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    route: '/home',
                  ),
                  _MobileNavItem(
                    icon: Icons.add_circle_outline,
                    label: 'Create',
                    route: '/create',
                  ),
                  _MobileNavItem(
                    icon: Icons.explore_outlined,
                    label: 'Explore',
                    route: '/explore',
                  ),
                  _MobileNavItem(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    route: '/gallery',
                  ),
                  _MobileNavItem(
                    icon: Icons.queue_outlined,
                    label: 'Queue',
                    route: '/queue',
                    badge: '3',
                  ),
                ],
              ),
            ),

            const Divider(color: AppTheme.borderColor),

            // Settings
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String? badge;

  const _MobileNavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isActive ? AppTheme.primaryColor.withOpacity(0.1) : null,
        onTap: () {
          context.go(route);
          Navigator.pop(context); // Close drawer
        },
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav();

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            route: '/home',
            isActive: currentRoute == '/home',
          ),
          _BottomNavItem(
            icon: Icons.explore_outlined,
            label: 'Explore',
            route: '/explore',
            isActive: currentRoute == '/explore',
          ),
          _BottomNavItem(
            icon: Icons.add_circle,
            label: 'Create',
            route: '/create',
            isActive: currentRoute == '/create',
            isCenter: true,
          ),
          _BottomNavItem(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            route: '/gallery',
            isActive: currentRoute == '/gallery',
          ),
          _BottomNavItem(
            icon: Icons.queue_outlined,
            label: 'Queue',
            route: '/queue',
            isActive: currentRoute == '/queue',
            badge: '3',
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final bool isCenter;
  final String? badge;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    this.isCenter = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                  size: isCenter ? 32 : 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar();

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
