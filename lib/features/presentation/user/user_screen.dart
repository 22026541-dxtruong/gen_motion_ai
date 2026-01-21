import 'package:flutter/material.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:go_router/go_router.dart';

class UserScreen extends StatefulWidget {
  final String userId;

  const UserScreen({super.key, required this.userId});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Works', 'Likes', 'Collections'];
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      padding: const EdgeInsets.all(32),
                      child: _buildProfileHeader(),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: _tabs.map((e) => Tab(text: e)).toList(),
                      labelColor: AppTheme.textPrimary,
                      unselectedLabelColor: AppTheme.textSecondary,
                      indicatorColor: AppTheme.primaryColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: AppTheme.borderColor,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildGridContent(itemCount: 12),
                _buildGridContent(itemCount: 5),
                _buildGridContent(itemCount: 2),
              ],
            ),
          ),
          Positioned(
            top: 32,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/explore'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final isDesktop = Responsive.isDesktop(context);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(size: 120),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Creative Artist',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildFollowButton(),
                    const SizedBox(width: 12),
                    _buildShareButton(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${widget.userId}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatsRow(),
                const SizedBox(height: 16),
                const Text(
                  'Digital artist exploring the boundaries of AI generation. Creating motion from stillness.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Mobile Layout
    return Column(
      children: [
        _buildAvatar(size: 80),
        const SizedBox(height: 16),
        const Text(
          'Creative Artist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ID: ${widget.userId}',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatsRow(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFollowButton(),
            const SizedBox(width: 12),
            _buildShareButton(),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Digital artist exploring the boundaries of AI generation.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.accentPurple, AppTheme.accentPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.surfaceColor, width: 4),
      ),
      child: Center(
        child: Text(
          'C',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem('12', 'Following'),
        Container(
            height: 12,
            width: 1,
            color: AppTheme.borderColor,
            margin: const EdgeInsets.symmetric(horizontal: 16)),
        _buildStatItem('3.5k', 'Followers'),
        Container(
            height: 12,
            width: 1,
            color: AppTheme.borderColor,
            margin: const EdgeInsets.symmetric(horizontal: 16)),
        _buildStatItem('12.8k', 'Likes'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return context.isMobile ?
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
      )
     : Row(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    return ElevatedButton(
      onPressed: () => setState(() => _isFollowing = !_isFollowing),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isFollowing ? AppTheme.cardColor : AppTheme.primaryColor,
        foregroundColor:
            _isFollowing ? AppTheme.textPrimary : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
      ),
      child: Text(_isFollowing ? 'Following' : 'Follow'),
    );
  }

  Widget _buildShareButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.borderColor),
        foregroundColor: AppTheme.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Icon(Icons.share_outlined, size: 20),
    );
  }

  Widget _buildGridContent({required int itemCount}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isMobile(context)
            ? 2
            : (Responsive.isTablet(context) ? 3 : 4),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => context.push('/detail/$index'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://picsum.photos/seed/${index + 100}/400/600',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _tabBar,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
