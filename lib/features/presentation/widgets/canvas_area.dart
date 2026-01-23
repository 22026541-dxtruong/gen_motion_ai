import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:gen_motion_ai/features/presentation/canvas/canvas_provider.dart';
import 'package:gen_motion_ai/features/presentation/canvas/models.dart'
    as models;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

const double kLogicalWidth = 1000.0;

class CanvasArea extends ConsumerStatefulWidget {
  const CanvasArea({super.key});

  @override
  ConsumerState<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends ConsumerState<CanvasArea> {
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);
    final visibleIcons = ref.watch(visibleIconsProvider);
    final visibleSketches = ref.watch(visibleSketchesProvider);
    final visibleUserImages = ref.watch(visibleUserImagesProvider);
    final visibleUserVideos = ref.watch(visibleUserVideosProvider);
    final logicalHeight = kLogicalWidth / canvasState.aspectRatio.ratio;

    return Column(
      children: [
        // Aspect Ratio Selector
        _buildAspectRatioSelector(canvasState),

        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: canvasState.aspectRatio.ratio,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = constraints.maxWidth / kLogicalWidth;

                  return DragTarget<models.SmartIconType>(
                    onWillAcceptWithDetails: (details) =>
                        !canvasState.isDrawingMode,
                    onAcceptWithDetails: (details) {
                      final RenderBox? renderBox =
                          _canvasKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      if (renderBox != null) {
                        final localPosition = renderBox.globalToLocal(
                          details.offset,
                        );
                        ref
                            .read(canvasProvider.notifier)
                            .addIcon(details.data, localPosition / scale);
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        key: _canvasKey,
                        margin: EdgeInsets.all(context.isMobile ? 8 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: candidateData.isNotEmpty
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                            width: candidateData.isNotEmpty ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: kLogicalWidth,
                              height: logicalHeight,
                              child: GestureDetector(
                                onTapDown: (details) {
                                  if (!canvasState.isDrawingMode) {
                                    bool tappedOnElement = false;

                                    // Check user videos
                                    for (final video in visibleUserVideos.reversed) {
                                      if (_isPointOnUserVideo(
                                        video,
                                        details.localPosition,
                                      )) {
                                        ref
                                            .read(canvasProvider.notifier)
                                            .selectUserVideo(video.id);
                                        tappedOnElement = true;
                                        break;
                                      }
                                    }
                                    if (tappedOnElement) return;

                                    // Check user images (reversed for z-order)
                                    for (final img in visibleUserImages.reversed) {
                                      if (_isPointOnUserImage(
                                        img,
                                        details.localPosition,
                                      )) {
                                        ref
                                            .read(canvasProvider.notifier)
                                            .selectUserImage(img.id);
                                        tappedOnElement = true;
                                        break;
                                      }
                                    }
                                    if (tappedOnElement) return;

                                    // Check icons (reversed for z-order)
                                    for (final icon in visibleIcons.reversed) {
                                      if (_isPointOnIcon(
                                        icon,
                                        details.localPosition,
                                      )) {
                                        ref
                                            .read(canvasProvider.notifier)
                                            .selectIcon(icon.id);
                                        tappedOnElement = true;
                                        break;
                                      }
                                    }

                                    if (!tappedOnElement) {
                                      // Check sketches (reversed for z-order)
                                      for (final sketch
                                          in visibleSketches.reversed) {
                                        if (_isPointOnSketch(
                                          sketch,
                                          details.localPosition,
                                        )) {
                                          ref
                                              .read(canvasProvider.notifier)
                                              .selectSketch(sketch.id);
                                          tappedOnElement = true;
                                          break;
                                        }
                                      }
                                    }

                                    if (!tappedOnElement) {
                                      ref
                                          .read(canvasProvider.notifier)
                                          .selectIcon(null);
                                      ref
                                          .read(canvasProvider.notifier)
                                          .selectSketch(null);
                                      ref
                                          .read(canvasProvider.notifier)
                                          .selectUserImage(null);
                                      ref
                                          .read(canvasProvider.notifier)
                                          .selectUserVideo(null);
                                    }
                                  }
                                },
                                child: Stack(
                                  children: [
                                    // Grid
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: GridPainter(),
                                      ),
                                    ),

                                    // User Videos
                                    ...visibleUserVideos.map(
                                      (video) => _CanvasUserVideoWidget(
                                        key: ValueKey(video.id),
                                        video: video,
                                        canvasKey: _canvasKey,
                                      ),
                                    ),

                                    // User Images (Background layer)
                                    ...visibleUserImages.map(
                                      (img) => _CanvasUserImageWidget(
                                        key: ValueKey(img.id),
                                        image: img,
                                        canvasKey: _canvasKey,
                                      ),
                                    ),

                                    // Sketches (draggable)
                                    ...visibleSketches.map(
                                      (sketch) => _DraggableSketch(
                                        key: ValueKey(sketch.id),
                                        sketch: sketch,
                                        canvasKey: _canvasKey,
                                        isSelected:
                                            canvasState.selectedSketchId ==
                                            sketch.id,
                                      ),
                                    ),

                                    // Icons (draggable)
                                    ...visibleIcons.map(
                                      (icon) => _CanvasIconWidget(
                                        key: ValueKey(icon.id),
                                        icon: icon,
                                        canvasKey: _canvasKey,
                                      ),
                                    ),

                                    // Current sketch
                                    if (canvasState.isDrawingMode)
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: SketchStrokePainter(
                                            canvasState.currentSketchPoints,
                                            isAbsolute: true,
                                          ),
                                        ),
                                      ),

                                    // Sketch layer
                                    if (canvasState.isDrawingMode)
                                      Positioned.fill(
                                        child: _SketchLayer(
                                          onDrawing: _handleSketchDrawing,
                                          onDrawingEnd: _handleSketchEnd,
                                        ),
                                      ),

                                    // Drop hint
                                    if (candidateData.isNotEmpty)
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            'Drop here',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Empty state
                                    if (canvasState.icons.isEmpty &&
                                        canvasState.sketches.isEmpty &&
                                        canvasState.userImages.isEmpty &&
                                        canvasState.userVideos.isEmpty &&
                                        !canvasState.isDrawingMode)
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              size: 56,
                                              color: Colors.grey[300],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Drag icons or draw',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAspectRatioSelector(models.CanvasState state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 8 : 12,
        vertical: context.isMobile ? 6 : 8,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          Text(
            'Canvas:',
            style: TextStyle(
              fontSize: context.isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(width: context.isMobile ? 8 : 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: models.AspectRatio.values.map((ratio) {
                  final isSelected = state.aspectRatio == ratio;
                  return Padding(
                    padding: EdgeInsets.only(right: context.isMobile ? 4 : 6),
                    child: InkWell(
                      onTap: () =>
                          ref.read(canvasProvider.notifier).setAspectRatio(ratio),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.isMobile ? 12 : 10,
                          vertical: context.isMobile ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                          ),
                        ),
                        child: Text(
                          ratio.label,
                          style: TextStyle(
                            fontSize: context.isMobile ? 12 : 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSketchDrawing(Offset point) {
    ref
        .read(canvasProvider.notifier)
        .addDrawingPoint(
          point,
          Paint()
            ..color = AppTheme.primaryColor
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
  }

  void _handleSketchEnd() {
    ref.read(canvasProvider.notifier).finishSketch();
  }

  bool _isPointOnIcon(models.CanvasIcon icon, Offset touchPoint) {
    // 1. Translate
    Offset local = touchPoint - icon.position;

    // 2. Rotate
    final double rad = -icon.rotation * math.pi / 180.0;
    final double cosT = math.cos(rad);
    final double sinT = math.sin(rad);
    local = Offset(
      local.dx * cosT - local.dy * sinT,
      local.dx * sinT + local.dy * cosT,
    );

    // 3. Check bounds (Icon is square centered at 0,0 in local space)
    final double halfSize = icon.size / 2;
    return local.dx >= -halfSize &&
        local.dx <= halfSize &&
        local.dy >= -halfSize &&
        local.dy <= halfSize;
  }

  bool _isPointOnSketch(models.SketchStroke sketch, Offset touchPoint) {
    // 1. Translate
    Offset local = touchPoint - sketch.position;

    // 2. Rotate
    final double rad = -sketch.rotation * math.pi / 180.0;
    final double cosT = math.cos(rad);
    final double sinT = math.sin(rad);
    local = Offset(
      local.dx * cosT - local.dy * sinT,
      local.dx * sinT + local.dy * cosT,
    );

    // 3. Scale
    if (sketch.scale != 0) {
      local = local / sketch.scale;
    }

    // Check distance to segments
    const double hitThreshold = 10.0;
    final double threshold = (sketch.strokeWidth / 2) + hitThreshold;

    for (int i = 0; i < sketch.points.length - 1; i++) {
      final p1 = sketch.points[i].offset;
      final p2 = sketch.points[i + 1].offset;
      if (_distanceToSegment(local, p1, p2) <= threshold) return true;
    }

    if (sketch.points.length == 1) {
      if ((local - sketch.points.first.offset).distance <= threshold)
        return true;
    }

    return false;
  }

  double _distanceToSegment(Offset p, Offset a, Offset b) {
    final Offset pa = p - a;
    final Offset ba = b - a;
    final double magBa = ba.distanceSquared;
    if (magBa == 0) return (p - a).distance;
    final double h = (pa.dx * ba.dx + pa.dy * ba.dy) / magBa;
    final double t = h.clamp(0.0, 1.0);
    return (pa - ba * t).distance;
  }

  bool _isPointOnUserImage(models.UserImage img, Offset touchPoint) {
    // 1. Translate
    Offset local = touchPoint - img.position;

    // 2. Rotate
    final double rad = -img.rotation * math.pi / 180.0;
    final double cosT = math.cos(rad);
    final double sinT = math.sin(rad);
    local = Offset(
      local.dx * cosT - local.dy * sinT,
      local.dx * sinT + local.dy * cosT,
    );

    // 3. Check bounds
    final double halfWidth = img.size.width / 2;
    final double halfHeight = img.size.height / 2;
    return local.dx >= -halfWidth &&
        local.dx <= halfWidth &&
        local.dy >= -halfHeight &&
        local.dy <= halfHeight;
  }

  bool _isPointOnUserVideo(models.UserVideo video, Offset touchPoint) {
    // 1. Translate
    Offset local = touchPoint - video.position;

    // 2. Rotate
    final double rad = -video.rotation * math.pi / 180.0;
    final double cosT = math.cos(rad);
    final double sinT = math.sin(rad);
    local = Offset(
      local.dx * cosT - local.dy * sinT,
      local.dx * sinT + local.dy * cosT,
    );

    // 3. Check bounds
    final double halfWidth = video.size.width / 2;
    final double halfHeight = video.size.height / 2;
    return local.dx >= -halfWidth &&
        local.dx <= halfWidth &&
        local.dy >= -halfHeight &&
        local.dy <= halfHeight;
  }
}

// Draggable Sketch Widget
class _DraggableSketch extends ConsumerStatefulWidget {
  final models.SketchStroke sketch;
  final GlobalKey canvasKey;
  final bool isSelected;

  const _DraggableSketch({
    required Key key,
    required this.sketch,
    required this.canvasKey,
    required this.isSelected,
  }) : super(key: key);

  @override
  ConsumerState<_DraggableSketch> createState() => _DraggableSketchState();
}

class _DraggableSketchState extends ConsumerState<_DraggableSketch> {
  @override
  Widget build(BuildContext context) {
    final sketch = widget.sketch;

    return Positioned(
      left: sketch.position.dx - sketch.size.width / 2,
      top: sketch.position.dy - sketch.size.height / 2,
      width: sketch.size.width,
      height: sketch.size.height,
      child: Transform(
        transform: Matrix4.identity()
          ..rotateZ(sketch.rotation * 3.14159 / 180)
          ..scale(sketch.scale),
        alignment: Alignment.center,
        child: CustomPaint(
          painter: SketchStrokePainter(
            widget.sketch.points.map((p) {
              return models.DrawingPoint(
                offset: p.offset,
                paint: Paint()
                  ..color = widget.sketch.color
                  ..strokeWidth = widget.sketch.strokeWidth
                  ..strokeCap = StrokeCap.round
                  ..style = PaintingStyle.stroke,
                timestamp: p.timestamp,
              );
            }).toList(),
            isSelected: widget.isSelected,
          ),
        ),
      ),
    );
  }
}

class _CanvasUserVideoWidget extends ConsumerStatefulWidget {
  final models.UserVideo video;
  final GlobalKey canvasKey;

  const _CanvasUserVideoWidget({
    required Key key,
    required this.video,
    required this.canvasKey,
  }) : super(key: key);

  @override
  ConsumerState<_CanvasUserVideoWidget> createState() => _CanvasUserVideoWidgetState();
}

class _CanvasUserVideoWidgetState extends ConsumerState<_CanvasUserVideoWidget> {
  Offset? _startPos;
  Offset _accumulatedDelta = Offset.zero;
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(_CanvasUserVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.video.path != oldWidget.video.path) {
      _controller?.dispose();
      _isInitialized = false;
      _initializeController();
    }
  }

  Future<void> _initializeController() async {
    try {
      if (kIsWeb || widget.video.path.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.path));
      } else {
        _controller = VideoPlayerController.file(File(widget.video.path));
      }
      
      await _controller!.initialize();
      await _controller!.setVolume(widget.video.volume);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);
    final isSelected = ref.watch(canvasProvider).selectedUserVideoId == widget.video.id;

    // Sync video player with canvas timeline
    if (_isInitialized && _controller != null) {
      _controller!.setVolume(widget.video.volume);
      // Note: setPlaybackSpeed might not be supported on all platforms/formats perfectly
      // but we attempt it.
      if (_controller!.value.playbackSpeed != widget.video.playbackSpeed) {
        _controller!.setPlaybackSpeed(widget.video.playbackSpeed);
      }

      // Calculate target video time based on canvas time
      // Video Time = (CanvasTime - StartTime) * Speed + TrimStart
      final double relativeTime = canvasState.currentTime - widget.video.startTime;
      final double targetVideoTime = (relativeTime * widget.video.playbackSpeed) + widget.video.trimStart;

      if (canvasState.isPlaying) {
        if (!_controller!.value.isPlaying) {
          _controller!.play();
        }
        // Optional: Sync if drift is too large, but usually let it play
        final currentVideoPos = _controller!.value.position.inMilliseconds / 1000.0;
        if ((currentVideoPos - targetVideoTime).abs() > 0.5) {
           _controller!.seekTo(Duration(milliseconds: (targetVideoTime * 1000).toInt()));
        }
      } else {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        }
        // Seek to exact frame when paused
        _controller!.seekTo(Duration(milliseconds: (targetVideoTime * 1000).toInt()));
      }
    }

    return Positioned(
      left: widget.video.position.dx - widget.video.size.width / 2,
      top: widget.video.position.dy - widget.video.size.height / 2,
      child: GestureDetector(
        onPanStart: (details) {
          _startPos = widget.video.position;
          _accumulatedDelta = Offset.zero;
          ref.read(canvasProvider.notifier).selectUserVideo(widget.video.id);
        },
        onPanUpdate: (details) {
          if (_startPos == null) return;
          _accumulatedDelta += details.delta;
          ref.read(canvasProvider.notifier).updateUserVideoPosition(
            widget.video.id,
            _startPos! + _accumulatedDelta,
          );
        },
        onPanEnd: (_) {
          _startPos = null;
          _accumulatedDelta = Offset.zero;
        },
        child: Transform.rotate(
          angle: widget.video.rotation * 3.14159 / 180,
          child: Container(
            width: widget.video.size.width,
            height: widget.video.size.height,
            decoration: BoxDecoration(
              color: Colors.black87,
              border: isSelected
                  ? Border.all(color: Colors.red, width: 2)
                  : null,
            ),
            child: Stack(
              children: [
                if (_isInitialized && _controller != null)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  )
                else
                  Center(
                    child: Icon(
                      Icons.videocam,
                      size: 48,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(canvasProvider.notifier).deleteUserVideo(widget.video.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CanvasIconWidget extends ConsumerStatefulWidget {
  final models.CanvasIcon icon;
  final GlobalKey canvasKey;

  const _CanvasIconWidget({
    required Key key,
    required this.icon,
    required this.canvasKey,
  }) : super(key: key);

  @override
  ConsumerState<_CanvasIconWidget> createState() => _CanvasIconWidgetState();
}

class _CanvasIconWidgetState extends ConsumerState<_CanvasIconWidget> {
  Offset? _startPos;
  Offset _accumulatedDelta = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final isSelected =
        ref.watch(canvasProvider).selectedIconId == widget.icon.id;

    return Positioned(
      left: widget.icon.position.dx - widget.icon.size / 2,
      top: widget.icon.position.dy - widget.icon.size / 2,
      child: GestureDetector(
        onPanStart: (details) {
          _startPos = widget.icon.position;
          _accumulatedDelta = Offset.zero;
          ref.read(canvasProvider.notifier).selectIcon(widget.icon.id);
        },
        onPanUpdate: (details) {
          if (_startPos == null) return;
          _accumulatedDelta += details.delta;

          ref
              .read(canvasProvider.notifier)
              .updateIconPosition(
                widget.icon.id,
                _startPos! + _accumulatedDelta,
              );
        },
        onPanEnd: (_) {
          _startPos = null;
          _accumulatedDelta = Offset.zero;
        },
        child: Transform.rotate(
          angle: widget.icon.rotation * 3.14159 / 180,
          child: Opacity(
            opacity: widget.icon.opacity,
            child: Container(
              width: widget.icon.size,
              height: widget.icon.size,
              decoration: BoxDecoration(
                color: widget.icon.type.color.withOpacity(0.15),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : widget.icon.type.color,
                  width: isSelected ? 3 : 2,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      widget.icon.type.icon,
                      size: widget.icon.size * 0.5,
                      color: widget.icon.type.color,
                    ),
                  ),
                  if (widget.icon.selectedVariation != null)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.icon.selectedVariation!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: widget.icon.size > 60 ? 9 : 8,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(canvasProvider.notifier)
                              .deleteIcon(widget.icon.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SketchLayer extends StatelessWidget {
  final Function(Offset) onDrawing;
  final VoidCallback onDrawingEnd;

  const _SketchLayer({required this.onDrawing, required this.onDrawingEnd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => onDrawing(details.localPosition),
      onPanUpdate: (details) => onDrawing(details.localPosition),
      onPanEnd: (details) => onDrawingEnd(),
      onPanCancel: () => onDrawingEnd(),
      behavior: HitTestBehavior.opaque,
      child: Container(color: Colors.transparent),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 0.5;
    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SketchStrokePainter extends CustomPainter {
  final List<models.DrawingPoint> points;
  final bool isSelected;
  final bool isAbsolute;

  SketchStrokePainter(
    this.points, {
    this.isSelected = false,
    this.isAbsolute = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    if (!isAbsolute) {
      // Points are relative to center, so translate canvas to center
      canvas.translate(size.width / 2, size.height / 2);
    }

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final paint = isSelected
          ? (Paint()
              ..color = AppTheme.primaryColor
              ..strokeWidth = p1.paint.strokeWidth + 1
              ..strokeCap = p1.paint.strokeCap
              ..style = p1.paint.style)
          : p1.paint;
      canvas.drawLine(p1.offset, p2.offset, paint);
    }

    if (points.length == 1) {
      final p = points.first;
      final paint = isSelected
          ? (Paint()
              ..color = AppTheme.primaryColor
              ..strokeWidth = p.paint.strokeWidth + 1
              ..strokeCap = p.paint.strokeCap
              ..style = p.paint.style)
          : p.paint;
      canvas.drawLine(p.offset, p.offset, paint);
    }
  }

  @override
  bool shouldRepaint(SketchStrokePainter oldDelegate) =>
      points != oldDelegate.points ||
      isSelected != oldDelegate.isSelected ||
      isAbsolute != oldDelegate.isAbsolute;
}

class _CanvasUserImageWidget extends ConsumerStatefulWidget {
  final models.UserImage image;
  final GlobalKey canvasKey;

  const _CanvasUserImageWidget({
    required Key key,
    required this.image,
    required this.canvasKey,
  }) : super(key: key);

  @override
  ConsumerState<_CanvasUserImageWidget> createState() => _CanvasUserImageWidgetState();
}

class _CanvasUserImageWidgetState extends ConsumerState<_CanvasUserImageWidget> {
  Offset? _startPos;
  Offset _accumulatedDelta = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final isSelected = ref.watch(canvasProvider).selectedUserImageId == widget.image.id;

    return Positioned(
      left: widget.image.position.dx - widget.image.size.width / 2,
      top: widget.image.position.dy - widget.image.size.height / 2,
      child: GestureDetector(
        onPanStart: (details) {
          _startPos = widget.image.position;
          _accumulatedDelta = Offset.zero;
          ref.read(canvasProvider.notifier).selectUserImage(widget.image.id);
        },
        onPanUpdate: (details) {
          if (_startPos == null) return;
          _accumulatedDelta += details.delta;
          ref.read(canvasProvider.notifier).updateUserImagePosition(
            widget.image.id,
            _startPos! + _accumulatedDelta,
          );
        },
        onPanEnd: (_) {
          _startPos = null;
          _accumulatedDelta = Offset.zero;
        },
        child: Transform.rotate(
          angle: widget.image.rotation * 3.14159 / 180,
          child: Container(
            width: widget.image.size.width,
            height: widget.image.size.height,
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: (kIsWeb || widget.image.path.startsWith('http'))
                      ? Image.network(
                          widget.image.path,
                          fit: BoxFit.cover,
                          opacity: AlwaysStoppedAnimation(widget.image.opacity),
                        )
                      : Image.file(
                          File(widget.image.path),
                          fit: BoxFit.cover,
                          opacity: AlwaysStoppedAnimation(widget.image.opacity),
                        ),
                ),
                if (isSelected)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(canvasProvider.notifier).deleteUserImage(widget.image.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
