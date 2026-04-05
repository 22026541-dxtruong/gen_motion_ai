import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/file/video_download_service.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job.dto.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:gen_motion_ai/features/presentation/generate/generate_provider.dart';
import 'package:gen_motion_ai/features/presentation/widgets/network_video_player.dart';
import 'package:go_router/go_router.dart';

class GenerateFlowScreen extends ConsumerStatefulWidget {
  const GenerateFlowScreen({super.key});

  @override
  ConsumerState<GenerateFlowScreen> createState() => _GenerateFlowScreenState();
}

class _GenerateFlowScreenState extends ConsumerState<GenerateFlowScreen> {
  final _promptController = TextEditingController();
  final _negativePromptController = TextEditingController();
  String _selectedPresetId = _videoPresets.first.id;
  bool _isDownloadingVideo = false;

  @override
  void dispose() {
    _promptController.dispose();
    _negativePromptController.dispose();
    super.dispose();
  }

  Future<void> _downloadVideo(JobResultDto result) async {
    if (_isDownloadingVideo || result.downloadUrl == null) {
      return;
    }

    setState(() => _isDownloadingVideo = true);
    try {
      final saved = await ref
          .read(videoDownloadServiceProvider)
          .downloadVideo(
            url: result.downloadUrl!,
            suggestedFileName: 'job_${result.jobId}',
            mimeType: result.mimeType,
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
        setState(() => _isDownloadingVideo = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generateVideoProvider);
    final isDesktop = context.isDesktop;
    final colors = context.appColors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (context.isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Video',
                  style: TextStyle(
                    fontSize: context.isMobile ? 24 : 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload ảnh, tạo job video, theo dõi tiến trình và nhận signed URL kết quả.',
                  style: TextStyle(color: colors.textSecondary, height: 1.5),
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
                        'Create Video',
                        style: TextStyle(
                          fontSize: context.isMobile ? 24 : 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload ảnh, tạo job video, theo dõi tiến trình và nhận signed URL kết quả.',
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
                  onPressed: () => context.go('/queue'),
                  icon: const Icon(Icons.queue_play_next_outlined),
                  label: const Text('Open Queue'),
                ),
              ],
            ),
          const SizedBox(height: 20),
          if (state.errorMessage != null) ...[
            _ErrorBanner(
              message: state.errorMessage!,
              onDismiss: ref.read(generateVideoProvider.notifier).clearError,
            ),
            const SizedBox(height: 16),
          ],
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildControlPanel(context, state)),
                const SizedBox(width: 20),
                Expanded(flex: 6, child: _buildLivePanel(context, state)),
              ],
            )
          else
            Column(
              children: [
                _buildLivePanel(context, state),
                const SizedBox(height: 16),
                _buildControlPanel(context, state),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context, GenerateVideoState state) {
    final notifier = ref.read(generateVideoProvider.notifier);

    return Column(
      children: [
        _SectionCard(
          title: 'Input Image',
          subtitle: 'FE sẽ upload multipart lên `/assets/upload`.',
          child: Column(
            children: [
              _SelectedImageCard(
                bytes: state.selectedImageBytes,
                fileName: state.selectedFileName,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: context.isMobile ? constraints.maxWidth : null,
                        child: FilledButton.icon(
                          onPressed: state.isBusy
                              ? null
                              : () => notifier.pickInputImage(),
                          icon: state.isPickingImage
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(
                            state.hasSelectedImage
                                ? 'Replace Image'
                                : 'Choose Image',
                          ),
                        ),
                      ),
                      if (state.hasSelectedImage)
                        SizedBox(
                          width: context.isMobile ? constraints.maxWidth : null,
                          child: OutlinedButton.icon(
                            onPressed: state.isBusy
                                ? null
                                : notifier.clearSelectedImage,
                            icon: const Icon(Icons.close),
                            label: const Text('Clear'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Prompt',
          subtitle: 'Body sẽ được gửi vào `POST /jobs/video`.',
          child: Column(
            children: [
              TextField(
                controller: _promptController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText:
                      'Ví dụ: A cinematic slow camera move over a neon-lit city skyline',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _negativePromptController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Negative prompt (optional)',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Preset',
          subtitle: 'Khớp đúng catalog backend hiện có.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _videoPresets
                .map(
                  (preset) => _PresetTile(
                    preset: preset,
                    selected: preset.id == _selectedPresetId,
                    onTap: () => setState(() => _selectedPresetId = preset.id),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Run',
          subtitle: 'Upload ảnh, tạo job và bắt đầu poll kết quả.',
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: context.isMobile ? constraints.maxWidth : null,
                        child: FilledButton.icon(
                          onPressed: state.isBusy
                              ? null
                              : () => notifier.generateVideo(
                                  prompt: _promptController.text,
                                  negativePrompt:
                                      _negativePromptController.text,
                                  presetId: _selectedPresetId,
                                ),
                          icon: state.isUploading || state.isCreatingJob
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome_motion_outlined),
                          label: Text(
                            state.isUploading
                                ? 'Uploading image...'
                                : state.isCreatingJob
                                ? 'Creating job...'
                                : 'Generate Video',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: context.isMobile ? constraints.maxWidth : null,
                        child: OutlinedButton.icon(
                          onPressed: state.canCancelCurrentJob
                              ? notifier.cancelCurrentJob
                              : null,
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('Cancel'),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (context.isMobile) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/queue'),
                    icon: const Icon(Icons.queue_play_next_outlined),
                    label: const Text('Open Queue'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLivePanel(BuildContext context, GenerateVideoState state) {
    final colors = context.appColors;
    final result = state.currentResult;
    return _SectionCard(
      title: 'Live Result',
      subtitle:
          'Hiển thị trạng thái job hiện tại và video ngay khi có signed URL.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasResultVideo && result?.downloadUrl != null)
            NetworkVideoPlayer(
              videoUrl: result!.downloadUrl!,
              thumbnailUrl: result.thumbnail?.downloadUrl,
              autoPlay: true,
            )
          else if (result?.thumbnail?.downloadUrl != null)
            _NetworkImageCard(imageUrl: result!.thumbnail!.downloadUrl)
          else if (state.selectedImageBytes != null)
            _MemoryImageCard(bytes: state.selectedImageBytes!)
          else
            const _PlaceholderCard(
              icon: Icons.movie_creation_outlined,
              title: 'No media yet',
              subtitle: 'Ảnh đầu vào hoặc video kết quả sẽ hiển thị ở đây.',
            ),
          const SizedBox(height: 16),
          if (result == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                state.hasSelectedImage
                    ? 'Ảnh đầu vào đã sẵn sàng. Hãy nhập prompt và bấm Generate.'
                    : 'Chọn ảnh và preset để bắt đầu.',
                style: TextStyle(color: colors.textSecondary),
              ),
            )
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoTag(
                  label: result.status,
                  color: _statusColor(result.status),
                ),
                _InfoTag(
                  label: state.isRealtimeConnected
                      ? 'Realtime'
                      : state.isRealtimeConnecting
                      ? 'Connecting'
                      : 'Polling',
                  color: state.isRealtimeConnected
                      ? AppTheme.accentGreen
                      : state.isRealtimeConnecting
                      ? Colors.orangeAccent
                      : colors.textSecondary,
                ),
                if (result.presetId != null) _InfoTag(label: result.presetId!),
                if (result.tier != null) _InfoTag(label: result.tier!),
                _InfoTag(label: '${result.creditCost} credits'),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: result.progressValue,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 8),
            Text(
              '${result.progress}% complete',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            _MetaGrid(
              items: [
                _MetaItem('Job ID', result.jobId),
                _MetaItem('Provider', result.provider ?? 'modal'),
                _MetaItem('Model', result.modelName ?? 'Waiting'),
                _MetaItem(
                  'ETA',
                  result.estimatedDurationSeconds != null
                      ? '${result.estimatedDurationSeconds}s'
                      : 'Unknown',
                ),
              ],
            ),
            if (result.isTerminal && !state.hasResultVideo) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: result.status == 'FAILED'
                      ? Colors.redAccent.withOpacity(0.12)
                      : Colors.orangeAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: result.status == 'FAILED'
                        ? Colors.redAccent.withOpacity(0.3)
                        : Colors.orangeAccent.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  result.status == 'FAILED'
                      ? 'Job đã thất bại. Bạn có thể đổi prompt hoặc preset rồi chạy lại.'
                      : 'Job đã bị hủy. Bạn có thể giữ ảnh hiện tại và tạo job mới bất cứ lúc nào.',
                  style: TextStyle(
                    color: result.status == 'FAILED'
                        ? Colors.redAccent
                        : Colors.orangeAccent,
                  ),
                ),
              ),
            ],
            if (result.downloadUrl != null) ...[
              const SizedBox(height: 16),
              SelectableText(
                result.downloadUrl!,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 12),
              Wrap(
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
                        const SnackBar(content: Text('Đã copy download URL.')),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy URL'),
                  ),
                  FilledButton.icon(
                    onPressed: _isDownloadingVideo
                        ? null
                        : () => _downloadVideo(result),
                    icon: _isDownloadingVideo
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
                      _isDownloadingVideo ? 'Downloading...' : 'Download',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/queue'),
                    icon: const Icon(Icons.queue_play_next_outlined),
                    label: const Text('Open Queue'),
                  ),
                ],
              ),
            ],
            if (state.realtimeLogs.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Recent Logs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...state.realtimeLogs.reversed
                  .take(4)
                  .map(
                    (log) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.message),
                          const SizedBox(height: 6),
                          Text(
                            _formatLogTime(log.createdAt),
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
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: colors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SelectedImageCard extends StatelessWidget {
  const _SelectedImageCard({required this.bytes, required this.fileName});

  final Uint8List? bytes;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (bytes == null) {
      return const _PlaceholderCard(
        icon: Icons.image_outlined,
        title: 'No image selected',
        subtitle: 'Chọn một ảnh đầu vào để FE upload thành asset INPUT.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemoryImageCard(bytes: bytes!),
        if (fileName != null) ...[
          const SizedBox(height: 10),
          Text(
            fileName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _MemoryImageCard extends StatelessWidget {
  const _MemoryImageCard({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.memory(bytes, fit: BoxFit.cover),
      ),
    );
  }
}

class _NetworkImageCard extends StatelessWidget {
  const _NetworkImageCard({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: colors.textSecondary),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
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

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final _PresetOption preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: context.isMobile ? double.infinity : 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor.withOpacity(0.14)
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : colors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              preset.label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '${preset.creditCost} credits',
              style: const TextStyle(
                color: AppTheme.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${preset.tier} • ~${preset.etaSeconds}s',
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({required this.label, this.color = AppTheme.primaryColor});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: context.isMobile ? 160 : 220),
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
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.items});

  final List<_MetaItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isNarrowPhone =
        context.isMobile && MediaQuery.of(context).size.width < 360;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isNarrowPhone ? 1 : (context.isMobile ? 2 : 4),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isNarrowPhone ? 3.2 : (context.isMobile ? 2.2 : 2.8),
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.label,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

class _MetaItem {
  const _MetaItem(this.label, this.value);

  final String label;
  final String value;
}

class _PresetOption {
  const _PresetOption({
    required this.id,
    required this.label,
    required this.tier,
    required this.creditCost,
    required this.etaSeconds,
  });

  final String id;
  final String label;
  final String tier;
  final int creditCost;
  final int etaSeconds;
}

const _videoPresets = [
  _PresetOption(
    id: 'preview_ltx_i2v',
    label: 'LTX Preview I2V',
    tier: 'preview',
    creditCost: 5,
    etaSeconds: 300,
  ),
  _PresetOption(
    id: 'standard_wan22_ti2v',
    label: 'Wan 2.2 Standard TI2V',
    tier: 'standard',
    creditCost: 10,
    etaSeconds: 420,
  ),
  _PresetOption(
    id: 'turbo_wan22_i2v_a14b',
    label: 'Turbo Wan 2.2 I2V',
    tier: 'turbo',
    creditCost: 15,
    etaSeconds: 240,
  ),
  _PresetOption(
    id: 'quality_hunyuan_i2v',
    label: 'Hunyuan Quality I2V',
    tier: 'quality',
    creditCost: 20,
    etaSeconds: 1320,
  ),
];

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

String _formatLogTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}
