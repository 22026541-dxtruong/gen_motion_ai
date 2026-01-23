import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:go_router/go_router.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: context.isMobile
          ? FloatingActionButton.extended(
              onPressed: () => _showPublishModal(context),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Publish'),
            )
          : null,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            if (context.isMobile) SliverToBoxAdapter(child: const _SearchBar()),
            SliverToBoxAdapter(child: const _BannerCarousel()),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                delegate: _StickyTabBarDelegate(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isMobile ? 8 : 16,
                    ),
                    child: Row(
                      mainAxisAlignment: context.isDesktop
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.start,
                      children: [
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: AppTheme.textPrimary,
                          unselectedLabelColor: AppTheme.textSecondary,
                          indicatorColor: AppTheme.primaryColor,
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: Colors.transparent,
                          tabAlignment: TabAlignment.start,
                          tabs: const [
                            Tab(text: 'Recommended'),
                            Tab(text: 'Trending'),
                            Tab(text: 'New Arrivals'),
                            Tab(text: 'Realistic'),
                            Tab(text: 'Anime'),
                            Tab(text: '3D Animation'),
                          ],
                        ),
                        if (context.isDesktop) ...[
                          const _SearchBar(isDesktop: true),
                          FloatingActionButton.extended(
                            onPressed: () => _showPublishModal(context),
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: const Text('Publish'),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
                pinned: true,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            _ExploreTabContent(tabKey: 'Recommended'),
            _ExploreTabContent(tabKey: 'Trending'),
            _ExploreTabContent(tabKey: 'New Arrivals'),
            _ExploreTabContent(tabKey: 'Realistic'),
            _ExploreTabContent(tabKey: 'Anime'),
            _ExploreTabContent(tabKey: '3D Animation'),
          ],
        ),
      ),
    );
  }

  void _showPublishModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Publish Creation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Mock Media Selector
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select Video or Image generated',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a description or prompt used...',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Published successfully!'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Post to Community'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _banners = [
    {
      'image': 'https://picsum.photos/1200/600?random=1',
      'title': 'Explore the Community\'s\nImagination',
      'subtitle': 'Discover amazing videos generated by Kling AI creators',
    },
    {
      'image': 'https://picsum.photos/1200/600?random=2',
      'title': 'New V1.5 Model\nAvailable Now',
      'subtitle': 'Experience higher fidelity and better motion consistency',
    },
    {
      'image': 'https://picsum.photos/1200/600?random=3',
      'title': 'Weekly Challenge:\nCyberpunk City',
      'subtitle': 'Join the contest and win free credits',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _animateToPage(_currentPage);
    });
  }

  void _animateToPage(int page) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _manualNavigate(int direction) {
    _timer?.cancel();
    int next = (_currentPage + direction + _banners.length) % _banners.length;
    _animateToPage(next);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: isMobile ? 180 : 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                return _buildBannerItem(context, _banners[index], isMobile);
              },
            ),
            Positioned(
              bottom: 16,
              right: 24,
              child: Row(
                children: List.generate(
                  _banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(left: 6),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.primaryColor
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // Previous Button
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: () => _manualNavigate(-1),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    hoverColor: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            // Next Button
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: () => _manualNavigate(1),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    hoverColor: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerItem(
    BuildContext context,
    Map<String, String> data,
    bool isMobile,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(data['image']!, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.9), Colors.transparent],
              begin: Alignment.bottomLeft,
              end: Alignment.center,
            ),
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Featured',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data['title']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['subtitle']!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExploreTabContent extends StatefulWidget {
  final String tabKey;

  const _ExploreTabContent({required this.tabKey});

  @override
  State<_ExploreTabContent> createState() => _ExploreTabContentState();
}

class _ExploreTabContentState extends State<_ExploreTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isMobile = Responsive.isMobile(context);

    return CustomScrollView(
      key: PageStorageKey<String>(widget.tabKey),
      slivers: <Widget>[
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: EdgeInsets.all(isMobile ? 10 : 16),
          sliver: SliverGrid(
            gridDelegate: isMobile
                ? const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  )
                : const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              return _ExploreCard(index: index);
            }, childCount: 20),
          ),
        ),
      ],
    );
  }
}

class _ExploreCard extends StatefulWidget {
  final int index;
  const _ExploreCard({required this.index});

  @override
  State<_ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<_ExploreCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered && !isMobile
            ? (Matrix4.identity()..translate(0, -4, 0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered && !isMobile
                ? AppTheme.primaryColor.withOpacity(0.5)
                : AppTheme.borderColor,
          ),
          boxShadow: _isHovered && !isMobile
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= VIDEO / THUMBNAIL =================
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    context.push('/detail/${widget.index}');
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://picsum.photos/seed/${widget.index + 50}/400/600',
                        fit: BoxFit.cover,
                      ),
                      if (_isHovered || isMobile)
                        Container(
                          color: isMobile
                              ? Colors.transparent
                              : Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white.withOpacity(
                                isMobile ? 0.8 : 1.0,
                              ),
                              size: isMobile ? 32 : 48,
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '00:05',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ================= INFO =================
            Padding(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cinematic shot of a futuristic city with neon lights...',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: isMobile ? 12 : 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),

                  // ================= USER + LIKE =================
                  Row(
                    children: [
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              context.push('/user/user_${widget.index}');
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: isMobile ? 8 : 10,
                                  backgroundColor: AppTheme.accentPurple,
                                  child: Text(
                                    'U${widget.index}',
                                    style: TextStyle(
                                      fontSize: isMobile ? 7 : 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'User ${widget.index}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 4),

                      // LIKE BUTTON
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            // handle like
                          },
                          child: Row(
                            children: [
                              Icon(
                                _isHovered
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: isMobile ? 14 : 16,
                                color: _isHovered
                                    ? AppTheme.accentPink
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${245 + widget.index}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppTheme.backgroundColor, child: child);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}

class _SearchBar extends StatelessWidget {
  final bool isDesktop;

  const _SearchBar({this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Container(
        constraints: BoxConstraints(maxWidth: 400),
        height: 36,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search...',
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search prompts, styles, users...',
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
