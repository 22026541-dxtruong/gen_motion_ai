import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gen_motion_ai/features/presentation/canvas/canvas_provider.dart';
import 'package:gen_motion_ai/features/presentation/canvas/models.dart';
import 'package:gen_motion_ai/features/presentation/widgets/canvas_area.dart';
import 'package:gen_motion_ai/features/presentation/widgets/icon_library_panel.dart';
import 'package:gen_motion_ai/features/presentation/widgets/properties_panel.dart';
import 'package:gen_motion_ai/features/presentation/widgets/video_timeline.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class CanvasScreen extends ConsumerWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Responsive(
      mobile: const _MobileCanvasLayout(),
      desktop: const _DesktopCanvasLayout(),
    );
  }
}

// ==================== DESKTOP LAYOUT ====================
class _DesktopCanvasLayout extends ConsumerStatefulWidget {
  const _DesktopCanvasLayout();

  @override
  ConsumerState<_DesktopCanvasLayout> createState() =>
      _DesktopCanvasLayoutState();
}

class _DesktopCanvasLayoutState extends ConsumerState<_DesktopCanvasLayout> {
  double _leftPanelWidth = 280.0;
  double _rightPanelWidth = 280.0;
  double _timelineHeight = 250.0;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Left: Icon Library
              SizedBox(width: _leftPanelWidth, child: const IconLibraryPanel()),

              // Resizer Left
              MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _leftPanelWidth = (_leftPanelWidth + details.delta.dx)
                          .clamp(200.0, 500.0);
                    });
                  },
                  child: Container(width: 4, color: AppTheme.borderColor),
                ),
              ),

              // Center: Canvas Area
              const Expanded(child: _CanvasContainer()),

              // Resizer Right
              MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _rightPanelWidth = (_rightPanelWidth - details.delta.dx)
                          .clamp(200.0, 500.0);
                    });
                  },
                  child: Container(width: 4, color: AppTheme.borderColor),
                ),
              ),

              // Right: Properties Panel
              SizedBox(width: _rightPanelWidth, child: const PropertiesPanel()),
            ],
          ),
        ),

        // Bottom: Video Timeline (collapsible)
        if (canvasState.mode == GenerationMode.video &&
            canvasState.showTimeline) ...[
          // Resizer Bottom
          MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _timelineHeight = (_timelineHeight - details.delta.dy).clamp(
                    150.0,
                    600.0,
                  );
                });
              },
              child: Container(height: 4, color: AppTheme.borderColor),
            ),
          ),
          SizedBox(height: _timelineHeight, child: const VideoTimeline()),
        ],
      ],
    );
  }
}

// ==================== MOBILE LAYOUT ====================
class _MobileCanvasLayout extends ConsumerStatefulWidget {
  const _MobileCanvasLayout();

  @override
  ConsumerState<_MobileCanvasLayout> createState() =>
      _MobileCanvasLayoutState();
}

class _MobileCanvasLayoutState extends ConsumerState<_MobileCanvasLayout> {
  bool _showIconLibrary = false;
  bool _showProperties = false;
  double _timelineHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);
    final hasSelection =
        canvasState.selectedIconId != null ||
        canvasState.selectedSketchId != null ||
        canvasState.selectedUserImageId != null ||
        canvasState.selectedUserVideoId != null;

    // Tự động mở Properties khi chọn đối tượng mới
    ref.listen(canvasProvider, (previous, next) {
      final prevSelection =
          previous?.selectedIconId ??
          previous?.selectedSketchId ??
          previous?.selectedUserImageId ??
          previous?.selectedUserVideoId;
      final nextSelection =
          next.selectedIconId ??
          next.selectedSketchId ??
          next.selectedUserImageId ??
          next.selectedUserVideoId;

      if (nextSelection != null && nextSelection != prevSelection) {
        setState(() {
          _showProperties = true;
          _showIconLibrary = false;
        });
      } else if (nextSelection == null && prevSelection != null) {
        setState(() {
          _showProperties = false;
        });
      }
    });

    return Stack(
      children: [
        Column(
          children: [
            _buildMobileToolbar(canvasState, hasSelection),

            Expanded(child: const _CanvasContainer()),

            if (canvasState.mode == GenerationMode.video &&
                canvasState.showTimeline &&
                !_showIconLibrary &&
                !_showProperties)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _timelineHeight = (_timelineHeight - details.delta.dy)
                            .clamp(
                              100.0,
                              MediaQuery.of(context).size.height * 0.6,
                            );
                      });
                    },
                    child: Container(
                      height: 24,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceColor,
                        border: Border(
                          top: BorderSide(color: AppTheme.borderColor),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _timelineHeight,
                    child: const VideoTimeline(),
                  ),
                ],
              ),

            if (!_showIconLibrary && !_showProperties) _buildBottomToolbar(),

            if (_showIconLibrary)
              _buildBottomPanel(
                title: 'Library',
                onClose: () => setState(() => _showIconLibrary = false),
                child: const IconLibraryPanel(),
              ),

            if (_showProperties && hasSelection)
              _buildBottomPanel(
                title: 'Properties',
                onClose: () => setState(() => _showProperties = false),
                child: const PropertiesPanel(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomPanel({
    required String title,
    required VoidCallback onClose,
    required Widget child,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildMobileToolbar(CanvasState canvasState, bool hasSelection) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          // Mode toggle
          SegmentedButton<GenerationMode>(
            segments: GenerationMode.values.map((mode) {
              return ButtonSegment(
                value: mode,
                icon: Icon(mode.icon, size: 16),
              );
            }).toList(),
            selected: {canvasState.mode},
            onSelectionChanged: (Set<GenerationMode> selected) {
              ref.read(canvasProvider.notifier).setMode(selected.first);
            },
            style: ButtonStyle(visualDensity: VisualDensity.compact),
          ),

          const SizedBox(width: 4),

          // Toggle timeline (video mode only)
          if (canvasState.mode == GenerationMode.video)
            IconButton(
              icon: Icon(
                canvasState.showTimeline
                    ? Icons.expand_more
                    : Icons.expand_less,
              ),
              onPressed: () {
                ref.read(canvasProvider.notifier).toggleTimeline();
              },
              tooltip: canvasState.showTimeline
                  ? 'Hide timeline'
                  : 'Show timeline',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),

          IconButton(
            icon: Icon(
              canvasState.isDrawingMode ? Icons.edit : Icons.draw,
              color: canvasState.isDrawingMode ? AppTheme.primaryColor : null,
            ),
            onPressed: () {
              ref.read(canvasProvider.notifier).toggleDrawingMode();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),

          if (hasSelection)
            IconButton(
              icon: Icon(
                Icons.tune,
                color: _showProperties ? AppTheme.primaryColor : null,
              ),
              onPressed: () => setState(() {
                _showProperties = !_showProperties;
                if (_showProperties) _showIconLibrary = false;
              }),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),

          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(canvasProvider.notifier).clearCanvas();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages(WidgetRef ref) async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      final paths = images.map((e) => e.path).toList();
      ref.read(canvasProvider.notifier).addUserImages(paths);
    }
  }

  Future<void> _pickVideo(WidgetRef ref) async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      ref.read(canvasProvider.notifier).addUserVideo(video.path);
    }
  }

  Widget _buildBottomToolbar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _showIconLibrary = true);
                      if (ref.read(canvasProvider).isDrawingMode) {
                        ref.read(canvasProvider.notifier).toggleDrawingMode();
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Icons'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _pickImages(ref),
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
                    label: const Text('Images'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _pickVideo(ref),
                    icon: const Icon(Icons.video_library_outlined, size: 20),
                    label: const Text('Video'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _generateImage,
            icon: const Icon(Icons.auto_awesome, size: 20),
            label: const Text('Generate'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _generateImage() {
    final prompt = ref.read(canvasProvider.notifier).generatePrompt();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Generated Prompt'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(prompt, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 16),
              const Text(
                'This prompt will be used to generate your content.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Generating...')));
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}

// ==================== CANVAS CONTAINER ====================
class _CanvasContainer extends ConsumerWidget {
  const _CanvasContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);

    return Container(
      color: AppTheme.backgroundColor,
      child: Column(
        children: [
          if (!context.isMobile)
            _buildDesktopToolbar(context, ref, canvasState),

          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                    ),
                    margin: EdgeInsets.all(context.isMobile ? 0 : 24),
                    child: const CanvasArea(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages(WidgetRef ref) async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      final paths = images.map((e) => e.path).toList();
      ref.read(canvasProvider.notifier).addUserImages(paths);
    }
  }

  Future<void> _pickVideo(WidgetRef ref) async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      ref.read(canvasProvider.notifier).addUserVideo(video.path);
    }
  }

  Widget _buildDesktopToolbar(
    BuildContext context,
    WidgetRef ref,
    CanvasState canvasState,
  ) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Canvas Studio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 24),

          // Mode selector
          SegmentedButton<GenerationMode>(
            segments: GenerationMode.values.map((mode) {
              return ButtonSegment(
                value: mode,
                label: Text(mode.label),
                icon: Icon(mode.icon),
              );
            }).toList(),
            selected: {canvasState.mode},
            onSelectionChanged: (Set<GenerationMode> selected) {
              ref.read(canvasProvider.notifier).setMode(selected.first);
            },
          ),

          const SizedBox(width: 24),

          // Drawing mode toggle
          ToggleButtons(
            isSelected: [!canvasState.isDrawingMode, canvasState.isDrawingMode],
            onPressed: (index) {
              if (index == 1) {
                ref.read(canvasProvider.notifier).toggleDrawingMode();
              } else if (canvasState.isDrawingMode) {
                ref.read(canvasProvider.notifier).toggleDrawingMode();
              }
            },
            borderRadius: BorderRadius.circular(8),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.touch_app, size: 18),
                    SizedBox(width: 8),
                    Text('Select'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.draw, size: 18),
                    SizedBox(width: 8),
                    Text('Sketch'),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Timeline toggle (video mode)
          if (canvasState.mode == GenerationMode.video)
            TextButton.icon(
              onPressed: () {
                ref.read(canvasProvider.notifier).toggleTimeline();
              },
              icon: Icon(
                canvasState.showTimeline
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
              ),
              label: Text(
                canvasState.showTimeline ? 'Hide Timeline' : 'Show Timeline',
              ),
            ),

          const SizedBox(width: 8),

          // Add Images button
          TextButton.icon(
            onPressed: () => _pickImages(ref),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Add Images'),
          ),

          if (canvasState.mode == GenerationMode.video) ...[
            const SizedBox(width: 8),

            TextButton.icon(
              onPressed: () => _pickVideo(ref),
              icon: const Icon(Icons.video_library_outlined),
              label: const Text('Add Video'),
            ),
          ],

          const SizedBox(width: 8),

          // Clear button
          TextButton.icon(
            onPressed: () {
              ref.read(canvasProvider.notifier).clearCanvas();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear All'),
          ),

          const SizedBox(width: 8),

          // Generate button
          ElevatedButton.icon(
            onPressed: () => _showGenerateDialog(context, ref, canvasState),
            icon: const Icon(Icons.auto_awesome),
            label: Text('Generate ${canvasState.mode.label}'),
          ),
        ],
      ),
    );
  }

  void _showGenerateDialog(
    BuildContext context,
    WidgetRef ref,
    CanvasState canvasState,
  ) {
    final prompt = ref.read(canvasProvider.notifier).generatePrompt();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('Generate ${canvasState.mode.label}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(prompt),
              ),
              const SizedBox(height: 16),
              Text(
                canvasState.mode == GenerationMode.video
                    ? 'AI will generate a ${canvasState.videoDuration.toStringAsFixed(0)}-second video with your layout, keyframes, and sketches.'
                    : 'AI will generate an image based on your icons and sketches.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Generating ${canvasState.mode.label.toLowerCase()}...',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: Text(
              'Generate (${canvasState.mode == GenerationMode.video ? 50 : 10} credits)',
            ),
          ),
        ],
      ),
    );
  }
}
