import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job.dto.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:gen_motion_ai/features/presentation/queue/queue_provider.dart';
import 'package:go_router/go_router.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 5 Tabs: All, Images, Videos, Canvas, Prompts
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/create');
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text('Create'),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const _GalleryGrid(type: 'All'),
                const _GalleryGrid(type: 'Images'),
                const _GalleryGrid(type: 'Videos'),
                const _GalleryGrid(type: 'Canvas'),
                const _PromptsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (context.isMobile) ...[
            Text(
              'My Library',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Search and Filter Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: colors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search images, videos, prompts...',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {},
                  tooltip: 'Filter',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: colors.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: colors.border,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Images'),
              Tab(text: 'Videos'),
              Tab(text: 'Canvas'),
              Tab(text: 'Prompts'),
            ],
          ),
        ],
      ),
    );
  }
}

class _GalleryGrid extends ConsumerWidget {
  const _GalleryGrid({required this.type});

  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsQueueProvider);

    return jobsAsync.when(
      data: (jobs) {
        final filtered = _filterJobs(type, jobs);
        if (type == 'Canvas') {
          return const _GalleryPlaceholder(
            icon: Icons.draw_outlined,
            title: 'Canvas chưa nối backend',
            subtitle:
                'Màn này hiện chỉ hiển thị dữ liệu job/assets video thực tế.',
          );
        }

        if (filtered.isEmpty) {
          return _GalleryPlaceholder(
            icon: type == 'Videos'
                ? Icons.videocam_outlined
                : Icons.photo_library_outlined,
            title: 'Chưa có dữ liệu',
            subtitle:
                'Hãy tạo video ở màn Create rồi quay lại đây để xem output.',
          );
        }

        final crossAxisCount = context.isMobile
            ? 2
            : (context.width > 1400 ? 5 : (context.width > 1000 ? 4 : 3));

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _GalleryItemCard(job: filtered[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _GalleryPlaceholder(
        icon: Icons.error_outline,
        title: 'Không tải được thư viện',
        subtitle: error.toString(),
      ),
    );
  }
}

class _GalleryItemCard extends StatefulWidget {
  const _GalleryItemCard({required this.job});

  final JobSummaryDto job;

  @override
  State<_GalleryItemCard> createState() => _GalleryItemCardState();
}

class _GalleryItemCardState extends State<_GalleryItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final job = widget.job;
    final previewUrl = job.thumbnail?.downloadUrl ?? job.output?.downloadUrl;
    final isVideo = job.output?.downloadUrl != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go('/queue'),
        child: Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? AppTheme.primaryColor : colors.border,
              width: _isHovered ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (previewUrl != null)
                      Image.network(previewUrl, fit: BoxFit.cover)
                    else
                      Container(
                        color: Colors.grey[850],
                        child: Icon(
                          isVideo
                              ? Icons.play_circle_outline
                              : Icons.image_outlined,
                          color: Colors.white24,
                          size: 48,
                        ),
                      ),
                    if (_isHovered || context.isMobile)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: Icon(
                            Icons.open_in_new,
                            color: Colors.white,
                            size: 28,
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
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isVideo ? job.status : 'THUMB',
                          style: const TextStyle(
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
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.prompt,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${job.progress}% • ${job.status}',
                      style: TextStyle(
                        color: colors.textSecondary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptsList extends ConsumerWidget {
  const _PromptsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final jobsAsync = ref.watch(jobsQueueProvider);

    return jobsAsync.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return const _GalleryPlaceholder(
            icon: Icons.short_text_outlined,
            title: 'Chưa có prompt nào',
            subtitle: 'Prompt từ các job video sẽ hiển thị ở đây.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Video Prompt',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        job.status,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job.prompt,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colors.textSecondary,
                      ),
                      Text(
                        _formatGalleryDate(job.updatedAt),
                        style: TextStyle(
                          color: colors.textSecondary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/create'),
                        child: const Text('Use Again'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _GalleryPlaceholder(
        icon: Icons.error_outline,
        title: 'Không tải được prompts',
        subtitle: error.toString(),
      ),
    );
  }
}

class _GalleryPlaceholder extends StatelessWidget {
  const _GalleryPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: colors.textSecondary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

List<JobSummaryDto> _filterJobs(String type, List<JobSummaryDto> jobs) {
  switch (type) {
    case 'Images':
      return jobs
          .where((job) => job.thumbnail?.downloadUrl != null)
          .toList(growable: false);
    case 'Videos':
      return jobs
          .where((job) => job.output?.downloadUrl != null)
          .toList(growable: false);
    case 'Canvas':
      return const <JobSummaryDto>[];
    default:
      return jobs.toList(growable: false);
  }
}

String _formatGalleryDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}
