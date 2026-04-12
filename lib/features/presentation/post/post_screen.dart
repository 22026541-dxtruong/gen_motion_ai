import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/post/dto/get_post.dto.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:go_router/go_router.dart';

final _postDetailProvider =
    FutureProvider.family<GetPostDto?, String>((ref, postId) async {
  final api = ref.read(postApiProvider);
  try {
    return await api.getPost(postId);
  } catch (_) {
    return null;
  }
});

class PostScreen extends ConsumerWidget {
  final String postId;
  const PostScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(_postDetailProvider(postId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/explore');
            }
          },
        ),
        title: const Text('Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: postAsync.when(
        data: (post) {
          if (post == null) {
            return const Center(
              child: Text('Post not found', style: TextStyle(color: AppTheme.textSecondary)),
            );
          }
          return _PostContent(post: post, postId: postId);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 12),
              const Text('Failed to load post'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.refresh(_postDetailProvider(postId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostContent extends ConsumerStatefulWidget {
  final GetPostDto post;
  final String postId;
  const _PostContent({required this.post, required this.postId});

  @override
  ConsumerState<_PostContent> createState() => _PostContentState();
}

class _PostContentState extends ConsumerState<_PostContent> {
  late bool _isLiked;
  late int _likeCount;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      final likeApi = ref.read(postLikeApiProvider);
      if (_isLiked) {
        await likeApi.likePost(widget.postId);
      } else {
        await likeApi.unlikePost(widget.postId);
      }
    } catch (_) {
      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDesktop = Responsive.isDesktop(context);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media
          Expanded(flex: 3, child: _buildMediaSection(post)),
          Container(width: 1, color: AppTheme.borderColor),
          // Info panel
          Expanded(flex: 2, child: _buildInfoPanel(post)),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMediaSection(post),
          _buildInfoPanel(post),
        ],
      ),
    );
  }

  Widget _buildMediaSection(GetPostDto post) {
    final fileUrl = post.assetVersion?.fileUrl;
    return Container(
      constraints: BoxConstraints(
        minHeight: context.isMobile ? 300 : 400,
        maxHeight: context.isMobile ? 400 : double.infinity,
      ),
      color: AppTheme.surfaceColor,
      child: fileUrl != null
          ? Image.network(
              fileUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (_, __, ___) => _mediaPlaceholder(),
            )
          : _mediaPlaceholder(),
    );
  }

  Widget _mediaPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48,
              color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          const Text('Media unavailable',
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(GetPostDto post) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                backgroundImage: post.user?.avatarUrl != null
                    ? NetworkImage(post.user!.avatarUrl!)
                    : null,
                child: post.user?.avatarUrl == null
                    ? Text(
                        (post.user?.username ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user?.username ?? 'Creator',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatTime(post.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  side: BorderSide(
                    color: post.isFollowed
                        ? AppTheme.textSecondary
                        : AppTheme.primaryColor,
                  ),
                  foregroundColor: post.isFollowed
                      ? AppTheme.textSecondary
                      : AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  post.isFollowed ? 'Following' : 'Follow',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Caption
          if (post.caption != null && post.caption!.isNotEmpty) ...[
            Text(
              post.caption!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 14),
          ],

          // Action bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.borderColor),
                bottom: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_outline,
                  label: '$_likeCount',
                  color: _isLiked ? Colors.redAccent : AppTheme.textSecondary,
                  onTap: _toggleLike,
                ),
                _actionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.commentCount}',
                  color: AppTheme.textSecondary,
                  onTap: () {},
                ),
                _actionButton(
                  icon: Icons.visibility_outlined,
                  label: '${post.viewCount}',
                  color: AppTheme.textSecondary,
                  onTap: () {},
                ),
                _actionButton(
                  icon: Icons.bookmark_outline,
                  label: 'Save',
                  color: AppTheme.textSecondary,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Comment input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    _commentController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comment posted')),
                    );
                  }
                },
                icon: const Icon(Icons.send, size: 20, color: AppTheme.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
