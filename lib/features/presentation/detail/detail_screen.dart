import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = int.tryParse(widget.id) ?? 0;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            physics: Responsive.isDesktop(context)
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _DetailItem(id: index.toString());
            },
          ),
          if (Responsive.isDesktop(context))
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width / 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: const Offset(-24, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavButton(
                        icon: Icons.keyboard_arrow_up_rounded,
                        onTap: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _NavButton(
                        icon: Icons.keyboard_arrow_down_rounded,
                        filled: true,
                        onTap: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Fixed Back Button for both Mobile and Desktop
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _NavButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppTheme.primaryColor : AppTheme.cardColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: filled
              ? null
              : BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderColor),
                ),
          child: Icon(
            icon,
            color: filled ? Colors.white : AppTheme.textPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatefulWidget {
  final String id;

  const _DetailItem({required this.id});

  @override
  State<_DetailItem> createState() => _DetailItemState();
}

class _DetailItemState extends State<_DetailItem> {
  late final bool _isVideo;
  bool _isFollowing = false;
  bool _isLiked = false;
  int _likeCount = 1245;
  bool _isDescriptionExpanded = false;
  final String _description =
      "Just created this amazing scene using the new v1.5 model! The lighting effects are insane. 🐕🤖 #cyberpunk #aiart";

  @override
  void initState() {
    super.initState();
    _isVideo = (int.tryParse(widget.id) ?? 0) % 2 == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      );
  }

  Widget _buildMobileLayout() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full Screen Media
        _MediaPlaceholder(isVideo: _isVideo, isMobileFull: true),

        // 2. Gradient Overlay for text readability
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // 3. Right Side Actions (Reels style)
        Positioned(
          right: 16,
          bottom: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ReelAction(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatNumber(_likeCount),
                color: _isLiked ? Colors.red : Colors.white,
                onTap: () => setState(() => _isLiked = !_isLiked),
              ),
              const SizedBox(height: 20),
              _ReelAction(
                icon: Icons.chat_bubble_outline,
                label: '42',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppTheme.surfaceColor,
                    isScrollControlled: true,
                    builder: (context) => const _CommentsBottomSheet(),
                  );
                },
              ),
              const SizedBox(height: 20),
              const _ReelAction(icon: Icons.share_outlined, label: 'Share'),
              const SizedBox(height: 20),
              const _ReelAction(icon: Icons.more_horiz, label: 'More'),
            ],
          ),
        ),

        // 4. Bottom Info
        Positioned(
          left: 16,
          right: 80, // Space for right actions
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text('U',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'User Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(
                    () => _isDescriptionExpanded = !_isDescriptionExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _description,
                      maxLines: _isDescriptionExpanded ? null : 2,
                      overflow: _isDescriptionExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                    ),
                    if (!_isDescriptionExpanded)
                      const Text(
                        'Xem thêm',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left: Media Preview Area
        Expanded(
          flex: 2,
          child: Container(
            color: AppTheme.backgroundColor,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _MediaPlaceholder(isVideo: _isVideo),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right: Details Sidebar
        Container(
          width: 1,
          color: AppTheme.borderColor,
        ),
        Expanded(
          flex: 1,
          child: Container(
            constraints: const BoxConstraints(minWidth: 400, maxWidth: 600),
            color: AppTheme.surfaceColor,
            child: Column(
              children: [
                // Fixed Header: User Info, Description, Actions
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfo(),
                      const SizedBox(height: 16),
                      Text(_description,
                          style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 20),
                      _buildRecreateButton(),
                      const SizedBox(height: 20),
                      _buildInteractionRow(),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.borderColor),
                // Scrollable Comments Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildCommentsSection(),
                  ),
                ),
                // Comment Input
                _buildCommentInput(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.accentPurple, AppTheme.accentPink],
            ),
          ),
          child: const Center(
            child: Text('U',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('User Name',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text('Created 2 hours ago',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.7))),
            ],
          ),
        ),
        SizedBox(
          height: 32,
          child: _isFollowing
              ? OutlinedButton(
                  onPressed: () => setState(() => _isFollowing = false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    side: const BorderSide(color: AppTheme.borderColor),
                    backgroundColor: AppTheme.cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Following',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary)),
                )
              : ElevatedButton(
                  onPressed: () => setState(() => _isFollowing = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Follow',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
        ),
      ],
    );
  }

  Widget _buildInteractionRow() {
    return Row(
      children: [
        _InteractionItem(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          label: _formatNumber(_likeCount),
          color: _isLiked ? Colors.red : null,
          onTap: () => setState(() {
            _isLiked = !_isLiked;
            _likeCount += _isLiked ? 1 : -1;
          }),
        ),
        const SizedBox(width: 20),
        const _InteractionItem(
            icon: Icons.chat_bubble_outline_rounded, label: '42'),
        const SizedBox(width: 20),
        const _InteractionItem(icon: Icons.share_outlined, label: 'Share'),
      ],
    );
  }

  Widget _buildRecreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/create'),
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text('Try this prompt'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.cardColor,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppTheme.borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Comments',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Text('42',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCommentList(),
      ],
    );
  }

  Widget _buildCommentList() {
    return Column(
      children: [
        _CommentItem(
            user: 'Alice',
            text: 'Amazing work! The lighting is incredible.',
            time: '1h ago'),
        _CommentItem(
            user: 'Bob',
            text: 'Which model version is this?',
            time: '30m ago'),
        _CommentItem(
            user: 'Charlie', text: 'Can you share the seed?', time: '10m ago'),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: const Text('Me', style: TextStyle(fontSize: 10))),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('Add a comment...',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: AppTheme.cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _CommentsBottomSheet extends StatelessWidget {
  const _CommentsBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Comments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                _CommentItem(
                    user: 'Alice',
                    text: 'Amazing work! The lighting is incredible.',
                    time: '1h ago'),
                _CommentItem(
                    user: 'Bob',
                    text: 'Which model version is this?',
                    time: '30m ago'),
                _CommentItem(
                    user: 'Charlie',
                    text: 'Can you share the seed?',
                    time: '10m ago'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _InteractionItem({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color ?? AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color ?? AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final String user;
  final String text;
  final String time;

  const _CommentItem({
    required this.user,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentPurple.withOpacity(0.6),
                  AppTheme.accentPink.withOpacity(0.6),
                ],
              ),
            ),
            child: Center(
              child: Text(
                user[0],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary.withOpacity(0.9),
                    height: 1.5,
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

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ReelAction({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaPlaceholder extends StatefulWidget {
  final bool isVideo;
  final bool isMobileFull;

  const _MediaPlaceholder({
    super.key,
    required this.isVideo,
    this.isMobileFull = false,
  });

  @override
  State<_MediaPlaceholder> createState() => _MediaPlaceholderState();
}

class _MediaPlaceholderState extends State<_MediaPlaceholder> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    );

    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);
      if (widget.isMobileFull) {
        await _controller!.play();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVideo) {
      if (!_isInitialized || _controller == null) {
        return Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );
      }

      Widget videoView = VideoPlayer(_controller!);

      if (widget.isMobileFull) {
        videoView = Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        );
      } else {
        videoView = AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        );
      }

      return GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          alignment: Alignment.center,
          children: [
            videoView,
            if (!_controller!.value.isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppTheme.primaryColor,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.isMobileFull) {
      return Image.network(
        'https://picsum.photos/seed/gen_motion_ai/800/1200',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://picsum.photos/seed/gen_motion_ai/800/800',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
