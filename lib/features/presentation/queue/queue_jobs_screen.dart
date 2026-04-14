import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/file/video_download_service.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job.dto.dart';
import 'package:gen_motion_ai/core/data/network/network_error.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:gen_motion_ai/features/presentation/queue/queue_provider.dart';
import 'package:gen_motion_ai/features/presentation/widgets/network_video_player.dart';

class QueueJobsScreen extends ConsumerStatefulWidget {
  const QueueJobsScreen({super.key});

  @override
  ConsumerState<QueueJobsScreen> createState() => _QueueJobsScreenState();
}

class _QueueJobsScreenState extends ConsumerState<QueueJobsScreen> {
  Timer? _refreshTimer;
  final Set<String> _pendingCancelIds = <String>{};
  final Set<String> _downloadingJobIds = <String>{};

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        ref.read(jobsQueueProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsQueueProvider);
    final colors = context.appColors;

    return RefreshIndicator(
      onRefresh: () => ref.read(jobsQueueProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(context.isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (context.isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Render Queue',
                    style: TextStyle(
                      fontSize: context.isMobile ? 24 : 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Theo dõi job video, mở preview kết quả và hủy job khi cần.',
                    style: TextStyle(color: colors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(jobsQueueProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Render Queue',
                          style: TextStyle(
                            fontSize: context.isMobile ? 24 : 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Theo dõi job video, mở preview kết quả và hủy job khi cần.',
                          style: TextStyle(
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(jobsQueueProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            jobsAsync.when(
              data: _buildContent,
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => _ErrorState(
                message: networkErrorMessage(error),
                onRetry: () => ref.read(jobsQueueProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<JobSummaryDto> jobs) {
    if (jobs.isEmpty) {
      return const _EmptyState();
    }

    final active = jobs.where((job) => !job.isTerminal).length;
    final completed = jobs.where((job) => job.status == 'COMPLETED').length;
    final failed = jobs.where((job) => job.status == 'FAILED').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsGrid(
          total: jobs.length,
          active: active,
          completed: completed,
          failed: failed,
        ),
        const SizedBox(height: 24),
        const Text(
          'Jobs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...jobs.map(
          (job) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _JobCard(
              job: job,
              isCancelling: _pendingCancelIds.contains(job.id),
              onPreview: () => _showPreviewDialog(job.id),
              onDetail: () => _showDetailSheet(job.id),
              onCancel: job.canCancel ? () => _cancelJob(job.id) : null,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _cancelJob(String jobId) async {
    setState(() => _pendingCancelIds.add(jobId));
    try {
      await ref.read(jobsQueueProvider.notifier).cancelJob(jobId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job đã được hủy.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(networkErrorMessage(error))));
    } finally {
      if (mounted) {
        setState(() => _pendingCancelIds.remove(jobId));
      }
    }
  }

  Future<void> _downloadVideo({
    required String jobId,
    required String url,
    String? mimeType,
  }) async {
    if (_downloadingJobIds.contains(jobId)) {
      return;
    }

    setState(() => _downloadingJobIds.add(jobId));
    try {
      final saved = await ref
          .read(videoDownloadServiceProvider)
          .downloadVideo(
            url: url,
            suggestedFileName: 'job_$jobId',
            mimeType: mimeType,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Da tai video: ${saved.fileName}\n${saved.filePath}'),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Khong tai duoc video: $error')));
    } finally {
      if (mounted) {
        setState(() => _downloadingJobIds.remove(jobId));
      }
    }
  }

  Future<void> _showPreviewDialog(String jobId) async {
    final colors = context.appColors;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: context.appColors.surface,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<JobResultDto>(
                future: ref.read(jobsApiProvider).getJobResult(jobId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _PreviewState(
                      message: networkErrorMessage(snapshot.error!),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const _PreviewState(
                      message: 'Không lấy được dữ liệu preview từ server.',
                    );
                  }

                  final result = snapshot.data!;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Job Preview',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (result.downloadUrl != null)
                        NetworkVideoPlayer(
                          videoUrl: result.downloadUrl!,
                          thumbnailUrl: result.thumbnail?.downloadUrl,
                          autoPlay: true,
                        )
                      else if (result.thumbnail?.downloadUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(result.thumbnail!.downloadUrl),
                        )
                      else
                        _PreviewState(
                          message:
                              'Job này chưa có output để preview.\nStatus: ${result.status} • ${result.progress}%',
                        ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Tag(
                            label: result.status,
                            color: _statusColor(result.status),
                          ),
                          if (result.presetId != null)
                            _Tag(label: result.presetId!),
                          if (result.modelName != null)
                            _Tag(label: result.modelName!),
                        ],
                      ),
                      if (result.downloadUrl != null) ...[
                        const SizedBox(height: 16),
                        SelectableText(
                          result.downloadUrl!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: result.downloadUrl!),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã copy download URL.'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_outlined),
                                label: const Text('Copy URL'),
                              ),
                              FilledButton.icon(
                                onPressed:
                                    _downloadingJobIds.contains(result.jobId)
                                    ? null
                                    : () => _downloadVideo(
                                        jobId: result.jobId,
                                        url: result.downloadUrl!,
                                        mimeType: result.mimeType,
                                      ),
                                icon: _downloadingJobIds.contains(result.jobId)
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.download_outlined),
                                label: Text(
                                  _downloadingJobIds.contains(result.jobId)
                                      ? 'Downloading...'
                                      : 'Download',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDetailSheet(String jobId) async {
    final colors = context.appColors;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          maxChildSize: 0.95,
          minChildSize: 0.55,
          builder: (context, scrollController) {
            return FutureBuilder<JobDetailDto>(
              future: ref.read(jobsApiProvider).getJobById(jobId),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(networkErrorMessage(snapshot.error!)),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Không lấy được dữ liệu chi tiết job.'),
                    ),
                  );
                }

                final detail = snapshot.data!;
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Job Detail',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(detail.prompt, style: const TextStyle(height: 1.5)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Tag(
                          label: detail.status,
                          color: _statusColor(detail.status),
                        ),
                        if (detail.modelName != null)
                          _Tag(label: detail.modelName!),
                        if (detail.presetId != null)
                          _Tag(label: detail.presetId!),
                        _Tag(label: '${detail.creditCost} credits'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value:
                          (detail.progress.clamp(0, 100) as num).toDouble() /
                          100,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${detail.progress}% complete',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    if (detail.errorMessage != null &&
                        detail.errorMessage!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          detail.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                    if (detail.thumbnail?.downloadUrl != null) ...[
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(detail.thumbnail!.downloadUrl),
                      ),
                    ],
                    if (detail.output?.downloadUrl != null) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: detail.output!.downloadUrl),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã copy download URL.'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_outlined),
                            label: const Text('Copy URL'),
                          ),
                          FilledButton.icon(
                            onPressed: _downloadingJobIds.contains(detail.id)
                                ? null
                                : () => _downloadVideo(
                                    jobId: detail.id,
                                    url: detail.output!.downloadUrl,
                                    mimeType: detail.output!.mimeType,
                                  ),
                            icon: _downloadingJobIds.contains(detail.id)
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.download_outlined),
                            label: Text(
                              _downloadingJobIds.contains(detail.id)
                                  ? 'Downloading...'
                                  : 'Download Video',
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      'Logs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (detail.logs.isEmpty)
                      Text(
                        'Chưa có log nào được trả về.',
                        style: TextStyle(color: colors.textSecondary),
                      )
                    else
                      ...detail.logs.map(
                        (log) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.message),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(log.createdAt),
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.total,
    required this.active,
    required this.completed,
    required this.failed,
  });

  final int total;
  final int active;
  final int completed;
  final int failed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isNarrowPhone =
        context.isMobile && MediaQuery.of(context).size.width < 360;
    final items = [
      ('Total', total.toString(), AppTheme.primaryColor),
      ('Active', active.toString(), AppTheme.accentPurple),
      ('Completed', completed.toString(), AppTheme.accentGreen),
      ('Failed', failed.toString(), Colors.redAccent),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isNarrowPhone ? 1 : (context.isMobile ? 2 : 4),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isNarrowPhone ? 3.2 : (context.isMobile ? 1.6 : 2.4),
      ),
      itemBuilder: (context, index) {
        final (label, value, color) = items[index];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: TextStyle(color: colors.textSecondary)),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.isCancelling,
    required this.onPreview,
    required this.onDetail,
    this.onCancel,
  });

  final JobSummaryDto job;
  final bool isCancelling;
  final VoidCallback onPreview;
  final VoidCallback onDetail;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isMobile = context.isMobile;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _Thumb(job: job),
                ),
                const SizedBox(height: 16),
                _JobCardContent(job: job),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumb(job: job),
                const SizedBox(width: 16),
                Expanded(child: _JobCardContent(job: job)),
              ],
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: onDetail,
                icon: const Icon(Icons.article_outlined),
                label: const Text('Details'),
              ),
              FilledButton.tonalIcon(
                onPressed: onPreview,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Preview'),
              ),
              if (onCancel != null)
                OutlinedButton.icon(
                  onPressed: isCancelling ? null : onCancel,
                  icon: isCancelling
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.stop_circle_outlined),
                  label: const Text('Cancel'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobCardContent extends StatelessWidget {
  const _JobCardContent({required this.job});

  final JobSummaryDto job;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Tag(label: job.status, color: _statusColor(job.status)),
            if (job.presetId != null) _Tag(label: job.presetId!),
            if (job.tier != null) _Tag(label: job.tier!),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          job.prompt,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: job.progressValue,
          minHeight: 8,
          borderRadius: BorderRadius.circular(999),
        ),
        const SizedBox(height: 8),
        Text(
          '${job.progress}% complete',
          style: TextStyle(color: colors.textSecondary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (job.modelName != null)
              _MutedInfo(icon: Icons.memory_outlined, text: job.modelName!),
            if (job.provider != null)
              _MutedInfo(icon: Icons.cloud_outlined, text: job.provider!),
            _MutedInfo(
              icon: Icons.schedule_outlined,
              text: _formatDate(job.updatedAt),
            ),
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.job});

  final JobSummaryDto job;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: context.isMobile ? 88 : 132,
        height: context.isMobile ? 88 : 132,
        color: colors.surface,
        child: job.thumbnail?.downloadUrl != null
            ? Image.network(job.thumbnail!.downloadUrl, fit: BoxFit.cover)
            : Icon(Icons.movie_creation_outlined, color: colors.textSecondary),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.color = AppTheme.primaryColor});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: context.isMobile ? 150 : 220),
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

class _MutedInfo extends StatelessWidget {
  const _MutedInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.isMobile ? 160 : 220),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: colors.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'Chưa có job nào',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy sang màn Create để bắt đầu tạo video đầu tiên.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 34),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _PreviewState extends StatelessWidget {
  const _PreviewState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 240,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
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
