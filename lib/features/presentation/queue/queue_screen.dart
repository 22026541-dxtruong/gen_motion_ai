import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Render Queue',
                style: TextStyle(
                  fontSize: context.isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!context.isMobile)
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Completed'),
                ),
            ],
          ),
          
          SizedBox(height: context.isMobile ? 16 : 24),
          
          // Queue stats
          context.isMobile 
            ? _buildMobileStats()
            : _buildDesktopStats(),
          
          SizedBox(height: context.isMobile ? 20 : 24),
          
          // Queue items
          const Text(
            'Active Tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ...[
            _QueueItem(
              title: 'Text to Image Generation',
              prompt: 'A beautiful sunset over mountains...',
              status: QueueStatus.processing,
              progress: 0.65,
              estimatedTime: '1 min remaining',
              isMobile: context.isMobile,
            ),
            const SizedBox(height: 12),
            _QueueItem(
              title: 'Image to Video',
              prompt: 'Animate landscape scene',
              status: QueueStatus.queued,
              estimatedTime: '~3 mins',
              isMobile: context.isMobile,
            ),
            const SizedBox(height: 12),
            _QueueItem(
              title: 'Image Enhancement',
              prompt: 'Upscale to 4K resolution',
              status: QueueStatus.queued,
              estimatedTime: '~5 mins',
              isMobile: context.isMobile,
            ),
          ],
          
          const SizedBox(height: 24),
          
          const Text(
            'Completed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          _QueueItem(
            title: 'Portrait Generation',
            prompt: 'Professional headshot, studio lighting',
            status: QueueStatus.completed,
            isMobile: context.isMobile,
          ),
          
          if (context.isMobile) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Completed'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileStats() {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: _StatCard(
              label: 'In Queue',
              value: '3',
              icon: Icons.queue,
              color: AppTheme.primaryColor,
            )),
            SizedBox(width: 12),
            Expanded(child: _StatCard(
              label: 'Processing',
              value: '1',
              icon: Icons.refresh,
              color: AppTheme.accentGreen,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: _StatCard(
              label: 'Completed',
              value: '12',
              icon: Icons.check_circle,
              color: AppTheme.accentPurple,
            )),
            SizedBox(width: 12),
            Expanded(child: _StatCard(
              label: 'Est. Time',
              value: '8m',
              icon: Icons.schedule,
              color: AppTheme.textSecondary,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopStats() {
    return Row(
      children: const [
        Expanded(child: _StatCard(
          label: 'In Queue',
          value: '3',
          icon: Icons.queue,
          color: AppTheme.primaryColor,
        )),
        SizedBox(width: 16),
        Expanded(child: _StatCard(
          label: 'Processing',
          value: '1',
          icon: Icons.refresh,
          color: AppTheme.accentGreen,
        )),
        SizedBox(width: 16),
        Expanded(child: _StatCard(
          label: 'Completed Today',
          value: '12',
          icon: Icons.check_circle,
          color: AppTheme.accentPurple,
        )),
        SizedBox(width: 16),
        Expanded(child: _StatCard(
          label: 'Estimated Time',
          value: '8 mins',
          icon: Icons.schedule,
          color: AppTheme.textSecondary,
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: context.isMobile ? 18 : 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: context.isMobile ? 12 : 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.isMobile ? 8 : 12),
            Text(
              value,
              style: TextStyle(
                fontSize: context.isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum QueueStatus {
  queued,
  processing,
  completed,
  failed,
}

class _QueueItem extends StatelessWidget {
  final String title;
  final String prompt;
  final QueueStatus status;
  final double? progress;
  final String? estimatedTime;
  final bool isMobile;

  const _QueueItem({
    required this.title,
    required this.prompt,
    required this.status,
    this.progress,
    this.estimatedTime,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Status icon
                _buildStatusIcon(),
                SizedBox(width: isMobile ? 12 : 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 6),
                      Text(
                        prompt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: isMobile ? 8 : 12),
                
                // Actions
                if (status != QueueStatus.completed)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {},
                    tooltip: 'Cancel',
                  ),
              ],
            ),
            
            // Progress bar (if processing)
            if (progress != null) ...[
              SizedBox(height: isMobile ? 10 : 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.borderColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress! * 100).toInt()}% complete',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (estimatedTime != null)
                    Text(
                      estimatedTime!,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
            
            // Estimated time (if queued)
            if (progress == null && estimatedTime != null) ...[
              SizedBox(height: isMobile ? 6 : 8),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    estimatedTime!,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            
            // Completed actions
            if (status == QueueStatus.completed) ...[
              SizedBox(height: isMobile ? 10 : 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text(
                        'View',
                        style: TextStyle(fontSize: isMobile ? 12 : 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 8 : 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download, size: 18),
                      label: Text(
                        'Download',
                        style: TextStyle(fontSize: isMobile ? 12 : 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 8 : 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (status) {
      case QueueStatus.queued:
        icon = Icons.schedule;
        color = AppTheme.textSecondary;
        break;
      case QueueStatus.processing:
        icon = Icons.refresh;
        color = AppTheme.accentGreen;
        break;
      case QueueStatus.completed:
        icon = Icons.check_circle;
        color = AppTheme.primaryColor;
        break;
      case QueueStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: isMobile ? 20 : 24),
    );
  }
}
