import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
class _DesktopCanvasLayout extends ConsumerWidget {
  const _DesktopCanvasLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);
    
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Left: Icon Library
              const SizedBox(
                width: 280,
                child: IconLibraryPanel(),
              ),
              
              // Center: Canvas Area
              const Expanded(
                child: _CanvasContainer(),
              ),
              
              // Right: Properties Panel
              SizedBox(
                width: 280,
                child: PropertiesPanel(),
              ),
            ],
          ),
        ),
        
        // Bottom: Video Timeline (collapsible)
        if (canvasState.mode == GenerationMode.video && canvasState.showTimeline)
          const VideoTimeline(),
      ],
    );
  }
}

// ==================== MOBILE LAYOUT ====================
class _MobileCanvasLayout extends ConsumerStatefulWidget {
  const _MobileCanvasLayout();

  @override
  ConsumerState<_MobileCanvasLayout> createState() => _MobileCanvasLayoutState();
}

class _MobileCanvasLayoutState extends ConsumerState<_MobileCanvasLayout> {
  bool _showIconLibrary = false;
  bool _showProperties = false;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);
    
    return Stack(
      children: [
        Column(
          children: [
            _buildMobileToolbar(canvasState),
            
            Expanded(
              child: const _CanvasContainer(),
            ),
            
            if (canvasState.mode == GenerationMode.video && canvasState.showTimeline)
              const VideoTimeline(),
            
            if (canvasState.mode == GenerationMode.image)
              _buildBottomToolbar(),
          ],
        ),
        
        // Drawers
        if (_showIconLibrary) _buildIconLibraryDrawer(),
        if (_showProperties && (canvasState.selectedIconId != null || canvasState.selectedSketchId != null))
          _buildPropertiesDrawer(),
      ],
    );
  }

  Widget _buildMobileToolbar(CanvasState canvasState) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Canvas Studio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          
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
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Toggle timeline (video mode only)
          if (canvasState.mode == GenerationMode.video)
            IconButton(
              icon: Icon(
                canvasState.showTimeline ? Icons.expand_more : Icons.expand_less,
              ),
              onPressed: () {
                ref.read(canvasProvider.notifier).toggleTimeline();
              },
              tooltip: canvasState.showTimeline ? 'Hide timeline' : 'Show timeline',
            ),
          
          IconButton(
            icon: Icon(
              canvasState.isDrawingMode ? Icons.edit : Icons.draw,
              color: canvasState.isDrawingMode ? AppTheme.primaryColor : null,
            ),
            onPressed: () {
              ref.read(canvasProvider.notifier).toggleDrawingMode();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(canvasProvider.notifier).clearCanvas();
            },
          ),
        ],
      ),
    );
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
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showIconLibrary = true),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Add Icons'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generateImage,
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: const Text('Generate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconLibraryDrawer() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showIconLibrary = false),
        child: Container(
          color: Colors.black54,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Expanded(child: IconLibraryPanel()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesDrawer() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showProperties = false),
        child: Container(
          color: Colors.black54,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(child: PropertiesPanel()),
                  ],
                ),
              ),
            ),
          ),
        ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating...')),
              );
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
          if (!context.isMobile) _buildDesktopToolbar(context, ref, canvasState),
          
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: context.isMobile ? double.infinity : 900,
                      maxHeight: context.isMobile ? double.infinity : 700,
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

  Widget _buildDesktopToolbar(BuildContext context, WidgetRef ref, CanvasState canvasState) {
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
                canvasState.showTimeline ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              ),
              label: Text(canvasState.showTimeline ? 'Hide Timeline' : 'Show Timeline'),
            ),
          
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

  void _showGenerateDialog(BuildContext context, WidgetRef ref, CanvasState canvasState) {
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
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
                  content: Text('Generating ${canvasState.mode.label.toLowerCase()}...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: Text('Generate (${canvasState.mode == GenerationMode.video ? 50 : 10} credits)'),
          ),
        ],
      ),
    );
  }
}
