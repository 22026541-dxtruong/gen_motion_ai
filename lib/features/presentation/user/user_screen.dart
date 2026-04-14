import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/user/dto/user.dto.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:gen_motion_ai/features/presentation/user/user_provider.dart';
import 'package:go_router/go_router.dart';

class UserScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserScreen({super.key, required this.userId});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Recent Jobs', 'About', 'Info'];

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
    final userAsync = ref.watch(userProvider(widget.userId));
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: userAsync.when(
        data: (user) => _buildBody(user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(UserDto? user) {
    final colors = context.appColors;
    return Stack(
      children: [
        NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    padding: const EdgeInsets.all(32),
                    child: _buildProfileHeader(user),
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: _tabs.map((e) => Tab(text: e)).toList(),
                    labelColor: colors.textPrimary,
                    unselectedLabelColor: colors.textSecondary,
                    indicatorColor: AppTheme.primaryColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: colors.border,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildRecentJobsTab(user),
              _buildAboutTab(user),
              _buildInfoTab(user),
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
    );
  }

  Widget _buildProfileHeader(UserDto? user) {
    final isDesktop = Responsive.isDesktop(context);
    final colors = context.appColors;

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
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text(
                        user?.username ?? 'User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    _buildPrimaryButton(),
                    _buildShareButton(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${widget.userId}',
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildStatsRow(user),
                const SizedBox(height: 16),
                Text(
                  user?.bio ?? 'Chưa có bio để hiển thị.',
                  style: TextStyle(
                    color: colors.textSecondary,
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
        Text(
          user?.username ?? 'User',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ID: ${widget.userId}',
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _buildStatsRow(user),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [_buildPrimaryButton(), _buildShareButton()],
        ),
        const SizedBox(height: 16),
        Text(
          user?.bio ?? 'Chưa có bio để hiển thị.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar({required double size}) {
    final colors = context.appColors;
    final user = ref.read(userProvider(widget.userId)).value;
    final initial = (user?.username.isNotEmpty ?? false)
        ? user!.username.characters.first.toUpperCase()
        : 'U';

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
        border: Border.all(color: colors.surface, width: 4),
      ),
      child: ClipOval(
        child: user?.avatarUrl != null
            ? Image.network(
                user!.avatarUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatsRow(UserDto? user) {
    final followers = user?.counts?.followers ?? 0;
    final following = user?.counts?.following ?? 0;
    final jobs = user?.counts?.jobs ?? user?.jobs?.data.length ?? 0;

    return Wrap(
      spacing: 20,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildStatItem(following.toString(), 'Following'),
        _buildStatItem(followers.toString(), 'Followers'),
        _buildStatItem(jobs.toString(), 'Jobs'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return context.isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          );
  }

  Widget _buildPrimaryButton() {
    final isMe = ref.read(currentUserProvider).value?.id == widget.userId;
    return ElevatedButton(
      onPressed: () => context.go(isMe ? '/queue' : '/explore'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
      ),
      child: Text(isMe ? 'Open Queue' : 'Explore'),
    );
  }

  Widget _buildShareButton() {
    final colors = context.appColors;
    return OutlinedButton(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: widget.userId));
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã copy user id.')));
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colors.border),
        foregroundColor: colors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Icon(Icons.copy_outlined, size: 20),
    );
  }

  Widget _buildRecentJobsTab(UserDto? user) {
    final colors = context.appColors;
    final jobs = user?.jobs?.data ?? const <UserJobDto>[];
    if (jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 40, color: colors.textSecondary),
              const SizedBox(height: 12),
              const Text(
                'Chưa có recent jobs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Nếu đây là tài khoản của bạn, hãy sang màn Create để bắt đầu tạo video.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go('/create'),
                icon: const Icon(Icons.auto_awesome_motion_outlined),
                label: const Text('Create Video'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final job = jobs[index];
        final progressValue =
            (job.progress.clamp(0, 100) as num).toDouble() / 100;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _UserJobTag(
                    label: job.status,
                    color: _statusColor(job.status),
                  ),
                  _UserJobTag(label: job.modelName),
                  _UserJobTag(label: '${job.creditCost} credits'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job.prompt,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 8),
              Text(
                '${job.progress}% complete',
                style: TextStyle(color: colors.textSecondary),
              ),
              if (job.errorMessage != null &&
                  job.errorMessage!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  job.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    'Provider: ${job.provider ?? 'modal'}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    'Updated: ${_formatDate(job.updatedAt)}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    'Turbo: ${job.turboEnabled ? 'On' : 'Off'}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutTab(UserDto? user) {
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Profile',
          children: [
            _InfoRow(label: 'Username', value: user?.username ?? 'User'),
            if (user?.email != null)
              _InfoRow(label: 'Email', value: user!.email!),
            _InfoRow(label: 'Role', value: user?.role ?? 'USER'),
            _InfoRow(
              label: 'Created',
              value: user?.createdAt != null
                  ? _formatDate(user!.createdAt!)
                  : 'Không có dữ liệu',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Bio',
          children: [
            Text(
              user?.bio?.trim().isNotEmpty == true
                  ? user!.bio!
                  : 'Chưa có bio để hiển thị.',
              style: TextStyle(color: colors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTab(UserDto? user) {
    final colors = context.appColors;
    final isMe = ref.read(currentUserProvider).value?.id == widget.userId;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Contract Notes',
          children: [
            Text(
              isMe
                  ? 'Màn này đang dùng dữ liệu thật từ `/users/me`, nên có thể hiển thị credits, counts và recent jobs.'
                  : 'Backend hiện chỉ trả thông tin rút gọn cho `/users/:id`, nên phần jobs/credits có thể không xuất hiện đầy đủ.',
              style: TextStyle(color: colors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Credits', value: '${user?.credits?.balance ?? 0}'),
            _InfoRow(
              label: 'Followers',
              value: '${user?.counts?.followers ?? 0}',
            ),
            _InfoRow(
              label: 'Following',
              value: '${user?.counts?.following ?? 0}',
            ),
            _InfoRow(
              label: 'Jobs',
              value: '${user?.counts?.jobs ?? user?.jobs?.data.length ?? 0}',
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(color: colors.textSecondary)),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserJobTag extends StatelessWidget {
  const _UserJobTag({required this.label, this.color = AppTheme.primaryColor});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

Color _statusColor(String status) {
  switch (status) {
    case 'COMPLETED':
      return AppTheme.accentGreen;
    case 'FAILED':
      return Colors.redAccent;
    case 'CANCELLED':
      return Colors.orangeAccent;
    case 'PROCESSING':
      return AppTheme.primaryColor;
    case 'QUEUED':
      return AppTheme.accentPurple;
    default:
      return const Color(0xFF7A869F);
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.appColors;
    return Container(
      color: colors.background,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          width: double.infinity,
          child: Align(alignment: Alignment.centerLeft, child: _tabBar),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
