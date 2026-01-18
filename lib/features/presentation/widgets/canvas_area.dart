import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/features/presentation/canvas/canvas_provider.dart';
import 'package:gen_motion_ai/features/presentation/canvas/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

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

    return Stack(
      children: [
        DragTarget<SmartIconType>(
          onWillAcceptWithDetails: (details) => !canvasState.isDrawingMode,
          onAcceptWithDetails: (details) {
            final RenderBox? renderBox =
                _canvasKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final localPosition = renderBox.globalToLocal(details.offset);
              final adjustedPosition = Offset(
                (localPosition.dx - canvasState.pan.dx) / canvasState.zoom,
                (localPosition.dy - canvasState.pan.dy) / canvasState.zoom,
              );
              ref
                  .read(canvasProvider.notifier)
                  .addIcon(details.data, adjustedPosition);
            }
          },
          builder: (context, candidateData, rejectedData) {
            return Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent && !canvasState.isDrawingMode) {
                  final delta = event.scrollDelta.dy;
                  final newZoom = canvasState.zoom * (1 - delta / 1000);
                  ref.read(canvasProvider.notifier).setZoom(newZoom);
                }
              },
              child: GestureDetector(
                onScaleStart: canvasState.isDrawingMode ? null : (details) {},
                onScaleUpdate: canvasState.isDrawingMode
                    ? null
                    : (details) {
                        if (details.pointerCount == 2) {
                          final newZoom = canvasState.zoom * details.scale;
                          ref.read(canvasProvider.notifier).setZoom(newZoom);
                        }
                      },
                onTapDown: (details) {
                  if (!canvasState.isDrawingMode) {
                    final RenderBox? renderBox =
                        _canvasKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    if (renderBox != null) {
                      final localPosition = details.localPosition;
                      final adjustedPosition = Offset(
                        (localPosition.dx - canvasState.pan.dx) /
                            canvasState.zoom,
                        (localPosition.dy - canvasState.pan.dy) /
                            canvasState.zoom,
                      );

                      bool tappedOnElement = false;

                      for (final icon in visibleIcons) {
                        final iconRect = Rect.fromCenter(
                          center: icon.position,
                          width: icon.size,
                          height: icon.size,
                        );
                        if (iconRect.contains(adjustedPosition)) {
                          tappedOnElement = true;
                          break;
                        }
                      }

                      if (!tappedOnElement) {
                        for (final sketch in visibleSketches) {
                          if (sketch.points.isNotEmpty) {
                            final bounds = _getSketchBounds(sketch.points);
                            if (bounds.inflate(20).contains(adjustedPosition)) {
                              ref
                                  .read(canvasProvider.notifier)
                                  .selectSketch(sketch.id);
                              tappedOnElement = true;
                              break;
                            }
                          }
                        }
                      }

                      if (!tappedOnElement) {
                        ref.read(canvasProvider.notifier).selectIcon(null);
                        ref.read(canvasProvider.notifier).selectSketch(null);
                      }
                    }
                  }
                },
                child: Container(
                  key: _canvasKey,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? AppTheme.primaryColor
                          : AppTheme.borderColor,
                      width: candidateData.isNotEmpty ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // INFINITE CANVAS - không giới hạn
                        final canvasWidth = constraints.maxWidth * 10;
                        final canvasHeight = constraints.maxHeight * 10;

                        return Stack(
                          children: [
                            // Transformed content with INFINITE bounds
                            Positioned.fill(
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..translate(
                                    canvasState.pan.dx,
                                    canvasState.pan.dy,
                                  )
                                  ..scale(canvasState.zoom),
                                child: SizedBox(
                                  width: canvasWidth,
                                  height: canvasHeight,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Grid
                                      Positioned(
                                        left: -canvasWidth / 2,
                                        top: -canvasHeight / 2,
                                        width: canvasWidth * 2,
                                        height: canvasHeight * 2,
                                        child: CustomPaint(
                                          painter: GridPainter(),
                                        ),
                                      ),

                                      // Sketches
                                      ...visibleSketches.map(
                                        (sketch) => Positioned.fill(
                                          child: CustomPaint(
                                            painter: SketchStrokePainter(
                                              sketch.points,
                                              isSelected:
                                                  canvasState
                                                      .selectedSketchId ==
                                                  sketch.id,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Icons - NO POSITIONING LIMITS
                                      ...visibleIcons.map(
                                        (icon) => _CanvasIconWidget(
                                          key: ValueKey(icon.id),
                                          icon: icon,
                                          canvasKey: _canvasKey,
                                          zoom: canvasState.zoom,
                                          pan: canvasState.pan,
                                        ),
                                      ),

                                      // Current sketch
                                      if (canvasState.isDrawingMode &&
                                          canvasState
                                              .currentSketchPoints
                                              .isNotEmpty)
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: SketchStrokePainter(
                                              canvasState.currentSketchPoints,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Sketch layer
                            if (canvasState.isDrawingMode)
                              Positioned.fill(
                                child: _SketchLayer(
                                  onDrawing: _handleSketchDrawing,
                                  onDrawingEnd: _handleSketchEnd,
                                  zoom: canvasState.zoom,
                                  pan: canvasState.pan,
                                ),
                              ),

                            // Drop hint
                            if (candidateData.isNotEmpty &&
                                !canvasState.isDrawingMode)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.9,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Drop here to add icon',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.isMobile ? 13 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                            // Empty state
                            if (canvasState.icons.isEmpty &&
                                canvasState.sketches.isEmpty &&
                                !canvasState.isDrawingMode)
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: context.isMobile ? 48 : 64,
                                      color: Colors.grey[300],
                                    ),
                                    SizedBox(
                                      height: context.isMobile ? 12 : 16,
                                    ),
                                    Text(
                                      'Drag icons or draw sketches',
                                      style: TextStyle(
                                        fontSize: context.isMobile ? 14 : 16,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    SizedBox(height: context.isMobile ? 6 : 8),
                                    Text(
                                      'Scroll to zoom • Tap & drag to move',
                                      style: TextStyle(
                                        fontSize: context.isMobile ? 12 : 13,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        Positioned(bottom: 16, right: 16, child: _CanvasControls()),
      ],
    );
  }

  void _handleSketchDrawing(Offset point) {
    ref
        .read(canvasProvider.notifier)
        .addDrawingPoint(
          point,
          Paint()
            ..color = AppTheme.primaryColor
            ..strokeWidth = context.isMobile ? 4 : 3
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
  }

  void _handleSketchEnd() {
    ref.read(canvasProvider.notifier).finishSketch();
  }

  Rect _getSketchBounds(List<DrawingPoint> points) {
    if (points.isEmpty) return Rect.zero;

    double minX = points.first.offset.dx;
    double maxX = points.first.offset.dx;
    double minY = points.first.offset.dy;
    double maxY = points.first.offset.dy;

    for (final point in points) {
      if (point.offset.dx < minX) minX = point.offset.dx;
      if (point.offset.dx > maxX) maxX = point.offset.dx;
      if (point.offset.dy < minY) minY = point.offset.dy;
      if (point.offset.dy > maxY) maxY = point.offset.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

class _CanvasControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);

    return Container(
      padding: EdgeInsets.all(context.isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.add, size: context.isMobile ? 16 : 18),
            onPressed: () {
              ref.read(canvasProvider.notifier).setZoom(canvasState.zoom * 1.2);
            },
            visualDensity: VisualDensity.compact,
            tooltip: 'Zoom in',
            padding: EdgeInsets.all(context.isMobile ? 6 : 8),
          ),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.isMobile ? 6 : 8,
              vertical: context.isMobile ? 3 : 4,
            ),
            child: Text(
              '${(canvasState.zoom * 100).toInt()}%',
              style: TextStyle(
                fontSize: context.isMobile ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          IconButton(
            icon: Icon(Icons.remove, size: context.isMobile ? 16 : 18),
            onPressed: () {
              ref.read(canvasProvider.notifier).setZoom(canvasState.zoom / 1.2);
            },
            visualDensity: VisualDensity.compact,
            tooltip: 'Zoom out',
            padding: EdgeInsets.all(context.isMobile ? 6 : 8),
          ),

          Divider(height: context.isMobile ? 8 : 12, thickness: 1),

          IconButton(
            icon: Icon(Icons.fit_screen, size: context.isMobile ? 16 : 18),
            onPressed: () {
              ref.read(canvasProvider.notifier).resetView();
            },
            visualDensity: VisualDensity.compact,
            tooltip: 'Reset view',
            padding: EdgeInsets.all(context.isMobile ? 6 : 8),
          ),
        ],
      ),
    );
  }
}

class _CanvasIconWidget extends ConsumerStatefulWidget {
  final CanvasIcon icon;
  final GlobalKey canvasKey;
  final double zoom;
  final Offset pan;

  const _CanvasIconWidget({
    required Key key,
    required this.icon,
    required this.canvasKey,
    required this.zoom,
    required this.pan,
  }) : super(key: key);

  @override
  ConsumerState<_CanvasIconWidget> createState() => _CanvasIconWidgetState();
}

class _CanvasIconWidgetState extends ConsumerState<_CanvasIconWidget> {
  Offset? _dragOffset;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);
    final isSelected = canvasState.selectedIconId == widget.icon.id;

    return Positioned(
      left: widget.icon.position.dx - widget.icon.size / 2,
      top: widget.icon.position.dy - widget.icon.size / 2,
      child: GestureDetector(
        onTapDown: (details) {
          ref.read(canvasProvider.notifier).selectIcon(widget.icon.id);
        },
        onPanStart: (details) {
          ref.read(canvasProvider.notifier).selectIcon(widget.icon.id);
          final RenderBox box =
              widget.canvasKey.currentContext!.findRenderObject() as RenderBox;

          final local = box.globalToLocal(details.globalPosition);

          // Chuột trong canvas space
          final canvasPos = Offset(
            (local.dx - widget.pan.dx) / widget.zoom,
            (local.dy - widget.pan.dy) / widget.zoom,
          );

          // Khoảng cách từ chuột → tâm icon
          _dragOffset = canvasPos - widget.icon.position;
        },
        onPanUpdate: (details) {
          if (_dragOffset == null) return;

          final RenderBox box =
              widget.canvasKey.currentContext!.findRenderObject() as RenderBox;

          final local = box.globalToLocal(details.globalPosition);

          final canvasPos = Offset(
            (local.dx - widget.pan.dx) / widget.zoom,
            (local.dy - widget.pan.dy) / widget.zoom,
          );
          ref
              .read(canvasProvider.notifier)
              .updateIconPosition(widget.icon.id, canvasPos - _dragOffset!);
          // if (_isDragging) {
          //   final adjustedDelta = Offset(
          //     details.delta.dx / widget.zoom,
          //     details.delta.dy / widget.zoom,
          //   );

          //   ref
          //       .read(canvasProvider.notifier)
          //       .updateIconPosition(
          //         widget.icon.id,
          //         widget.icon.position + adjustedDelta,
          //       );
          // }
        },
        onPanEnd: (details) {
          _dragOffset = null;
        },
        child: Transform.rotate(
          angle: widget.icon.rotation * 3.14159 / 180,
          child: Opacity(
            opacity: widget.icon.opacity,
            child: _buildIconContent(isSelected),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContent(bool isSelected) {
    return Container(
      width: widget.icon.size,
      height: widget.icon.size,
      decoration: BoxDecoration(
        color: widget.icon.type.color.withOpacity(0.15),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : widget.icon.type.color,
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
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                  ref.read(canvasProvider.notifier).deleteIcon(widget.icon.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SketchLayer extends StatelessWidget {
  final Function(Offset) onDrawing;
  final VoidCallback onDrawingEnd;
  final double zoom;
  final Offset pan;

  const _SketchLayer({
    required this.onDrawing,
    required this.onDrawingEnd,
    required this.zoom,
    required this.pan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final adjustedPosition = Offset(
          (details.localPosition.dx - pan.dx) / zoom,
          (details.localPosition.dy - pan.dy) / zoom,
        );
        onDrawing(adjustedPosition);
      },
      onPanEnd: (details) {
        onDrawingEnd();
      },
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
  final List<DrawingPoint> points;
  final bool isSelected;

  SketchStrokePainter(this.points, {this.isSelected = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

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
  }

  @override
  bool shouldRepaint(SketchStrokePainter oldDelegate) =>
      points != oldDelegate.points || isSelected != oldDelegate.isSelected;
}
