import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:gen_motion_ai/features/presentation/jobs/jobs_provider.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job_response_dto.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(jobsProvider.notifier).refresh();
      ref.read(jobsProvider.notifier).startPolling();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.isMobile ? 16 : 24,
              context.isMobile ? 12 : 20,
              context.isMobile ? 16 : 24,
              16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Queue',
                        style: TextStyle(
                          fontSize: context.isMobile ? 24 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitor your generation tasks',
                        style: TextStyle(
                          fontSize: context.isMobile ? 13 : 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(jobsProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh, size: 22),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: jobsAsync.when(
              data: (jobs) {
                if (jobs.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isMobile ? 16 : 24,
                  ),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) => _JobCard(job: jobs[index]),
                );
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
                    const Text('Failed to load jobs', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.read(jobsProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.hourglass_empty, size: 40, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          const Text(
            'No jobs yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first AI generation!',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  final JobResponseDto job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(job.status);
    final statusIcon = _getStatusIcon(job.status);
    final isActive = job.status == 'PENDING' || job.status == 'QUEUED' || job.status == 'PROCESSING';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? statusColor.withValues(alpha: 0.4) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: status + time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      job.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (job.type != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.type!.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                _formatTime(job.createdAt),
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Prompt
          if (job.prompt != null) ...[
            Text(
              job.prompt!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
          ],
          // Model info
          Row(
            children: [
              if (job.modelName != null) ...[
                Icon(Icons.smart_toy_outlined, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  job.modelName!,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 16),
              ],
              if (job.creditCost != null) ...[
                const Icon(Icons.bolt, size: 14, color: AppTheme.accentGreen),
                const SizedBox(width: 4),
                Text(
                  '${job.creditCost} credits',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ],
          ),
          // Progress bar
          if (isActive && job.progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (job.progress ?? 0) / 100,
                backgroundColor: AppTheme.surfaceColor,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${job.progress}%',
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
          // Error message
          if (job.errorMessage != null && job.status == 'FAILED') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.errorMessage!,
                      style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Action buttons
          if (isActive) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => ref.read(jobsProvider.notifier).cancelJob(job.effectiveId),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Cancel', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return AppTheme.accentGreen;
      case 'PROCESSING':
        return AppTheme.primaryColor;
      case 'QUEUED':
        return Colors.amber;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.redAccent;
      case 'CANCELLED':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'COMPLETED':
        return Icons.check_circle_outline;
      case 'PROCESSING':
        return Icons.autorenew;
      case 'QUEUED':
        return Icons.schedule;
      case 'PENDING':
        return Icons.hourglass_top;
      case 'FAILED':
        return Icons.error_outline;
      case 'CANCELLED':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
