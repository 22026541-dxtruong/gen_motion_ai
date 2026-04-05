import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/user/dto/user.dto.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:gen_motion_ai/features/presentation/auth/auth_provider.dart';
import 'package:gen_motion_ai/features/presentation/queue/queue_provider.dart';
import 'package:gen_motion_ai/features/presentation/user/user_provider.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child; // Thay đổi từ StatefulNavigationShell sang Widget
  final String location;

  const MainLayout({super.key, required this.child, required this.location});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final activeJobsCount = ref.watch(activeJobsCountProvider);
    return Scaffold(
      key: _scaffoldKey,
      drawer: context.isMobile
          ? _MobileDrawer(
              userAsync: userAsync,
              activeJobsCount: activeJobsCount,
            )
          : null,
      body: Responsive(
        mobile: _buildMobileLayout(widget.location, userAsync, activeJobsCount),
        desktop: _buildDesktopLayout(
          widget.location,
          userAsync,
          activeJobsCount,
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    String location,
    AsyncValue<UserDto?> userAsync,
    int activeJobsCount,
  ) {
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
        _MobileBottomNav(activeJobsCount: activeJobsCount),
      ],
    );
  }

  Widget _buildDesktopLayout(
    String location,
    AsyncValue<UserDto?> userAsync,
    int activeJobsCount,
  ) {
    return Row(
      children: [
        _DesktopSidebar(userAsync: userAsync, activeJobsCount: activeJobsCount),
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
      ],
    );
  }
}

class _DesktopSidebar extends ConsumerStatefulWidget {
  final AsyncValue<UserDto?> userAsync;
  final int activeJobsCount;

  const _DesktopSidebar({
    required this.userAsync,
    required this.activeJobsCount,
  });

  @override
  ConsumerState<_DesktopSidebar> createState() => __DesktopSidebarState();
}

class __DesktopSidebarState extends ConsumerState<_DesktopSidebar> {
  bool _collapsed = false;
  bool _hoverLogo = false;
  bool _expandedDone = true;

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final width = _collapsed ? 72.0 : 240.0;
    final colors = context.appColors;

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
                    Text(
                      'Gen Motion AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _ThemeModeButton(compact: true),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: colors.textSecondary,
                      ),
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

          Divider(color: colors.border),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _DesktopNavItem(
                  icon: Icons.explore_outlined,
                  label: 'Explore',
                  route: '/explore',
                  isActive: currentRoute == '/explore',
                  collapsed: !_expandedDone,
                ),
                _DesktopNavItem(
                  icon: Icons.draw_outlined,
                  label: 'Canvas',
                  route: '/canvas',
                  isActive: currentRoute == '/canvas',
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
                  badge: widget.activeJobsCount > 0
                      ? widget.activeJobsCount.toString()
                      : null,
                ),
              ],
            ),
          ),

          // User section
          Divider(color: colors.border),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              height: 56,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: widget.userAsync.value?.avatarUrl != null
                        ? NetworkImage(widget.userAsync.value!.avatarUrl!)
                        : null,
                    child: widget.userAsync.value?.avatarUrl == null
                        ? Text(
                            widget.userAsync.value?.username
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: const TextStyle(fontSize: 14),
                          )
                        : null,
                  ),
                  if (_expandedDone) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userAsync.value?.username ?? 'User',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                              Expanded(
                                child: Text(
                                  '${widget.userAsync.value?.credits?.balance ?? 0} credits',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _ThemeModeButton(compact: true),
                    IconButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (!context.mounted) return;
                        context.go('/login');
                      },
                      icon: Icon(
                        Icons.logout,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      tooltip: 'Logout',
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
    final colors = context.appColors;
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
                      : colors.textSecondary,
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
                            ? colors.textPrimary
                            : colors.textSecondary,
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
    final colors = context.appColors;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
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
          const Expanded(
            child: Text(
              'Gen Motion AI',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const _ThemeModeButton(),
        ],
      ),
    );
  }
}

class _MobileDrawer extends ConsumerWidget {
  final AsyncValue<UserDto?> userAsync;
  final int activeJobsCount;

  const _MobileDrawer({required this.userAsync, required this.activeJobsCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return Drawer(
      backgroundColor: colors.surface,
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
                    backgroundImage: userAsync.value?.avatarUrl != null
                        ? NetworkImage(userAsync.value!.avatarUrl!)
                        : null,
                    child: userAsync.value?.avatarUrl == null
                        ? Text(
                            userAsync.value?.username
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userAsync.value?.username ?? 'User',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                            Expanded(
                              child: Text(
                                '${userAsync.value?.credits?.balance ?? 0} credits',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                ),
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

            Divider(color: colors.border),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  _MobileNavItem(
                    icon: Icons.explore_outlined,
                    label: 'Explore',
                    route: '/explore',
                  ),
                  _MobileNavItem(
                    icon: Icons.draw_outlined,
                    label: 'Canvas',
                    route: '/canvas',
                  ),
                  _MobileNavItem(
                    icon: Icons.add_circle_outline,
                    label: 'Create',
                    route: '/create',
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
                    badge: activeJobsCount > 0
                        ? activeJobsCount.toString()
                        : null,
                  ),
                ],
              ),
            ),

            Divider(color: colors.border),

            // Settings
            ListTile(
              leading: Icon(
                context.isDarkTheme
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              title: Text(context.isDarkTheme ? 'Light mode' : 'Dark mode'),
              onTap: () => ref.read(themeModeProvider.notifier).toggle(),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: colors.textSecondary),
              title: Text(
                'Logout',
                style: TextStyle(color: colors.textSecondary),
              ),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (!context.mounted) return;
                context.go('/login');
              },
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
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppTheme.primaryColor : colors.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? colors.textPrimary : colors.textSecondary,
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
  final int activeJobsCount;

  const _MobileBottomNav({required this.activeJobsCount});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final colors = context.appColors;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.explore_outlined,
            label: 'Explore',
            route: '/explore',
            isActive: currentRoute == '/explore',
          ),
          _BottomNavItem(
            icon: Icons.draw_outlined,
            label: 'Canvas',
            route: '/canvas',
            isActive: currentRoute == '/canvas',
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
            badge: activeJobsCount > 0 ? activeJobsCount.toString() : null,
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
    final colors = context.appColors;
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
                      : colors.textSecondary,
                  size: isCenter ? 32 : 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive
                        ? AppTheme.primaryColor
                        : colors.textSecondary,
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

class _ThemeModeButton extends ConsumerWidget {
  const _ThemeModeButton({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final colors = context.appColors;
    final isDark = mode == ThemeMode.dark;
    final icon = isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined;
    final label = isDark ? 'Light' : 'Dark';

    if (compact) {
      return IconButton(
        onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
        tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        icon: Icon(icon, color: colors.textSecondary),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
