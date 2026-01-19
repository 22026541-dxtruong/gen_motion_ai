import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/features/presentation/canvas/canvas_provider.dart';
import 'package:gen_motion_ai/features/presentation/canvas/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class VideoTimeline extends ConsumerStatefulWidget {
  const VideoTimeline({super.key});

  @override
  ConsumerState<VideoTimeline> createState() => _VideoTimelineState();
}

class _VideoTimelineState extends ConsumerState<VideoTimeline> {
  double? _dragStartDx;
  double? _initialStartTime;
  double? _initialEndTime;

  String? _draggingId;
  String? _resizingId;
  bool _resizingStart = false;
  bool _isIcon = true;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);

    if (canvasState.mode != GenerationMode.video) {
      return const SizedBox.shrink();
    }

    return Container(
      height: context.isMobile ? 160 : 250,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: context.isMobile ? null : const Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Column(
        children: [
          _buildPlaybackControls(canvasState),

          const Divider(height: 1, color: AppTheme.borderColor),
          
          _buildTimeRuler(canvasState),
          const Divider(height: 1, color: AppTheme.borderColor),

          Expanded(child: _buildTimeline(canvasState)),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(CanvasState state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 4 : 16,
        vertical: context.isMobile ? 4 : 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (state.isPlaying) {
                ref.read(canvasProvider.notifier).pauseVideo();
              } else {
                ref.read(canvasProvider.notifier).playVideo();
              }
            },
            iconSize: context.isMobile ? 20 : 28,
            color: AppTheme.primaryColor,
            padding: EdgeInsets.all(context.isMobile ? 2 : 8),
            constraints: context.isMobile ? const BoxConstraints() : null,
          ),

          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              ref.read(canvasProvider.notifier).stopVideo();
            },
            iconSize: context.isMobile ? 20 : 28,
            padding: EdgeInsets.all(context.isMobile ? 2 : 8),
            constraints: context.isMobile ? const BoxConstraints() : null,
          ),

          SizedBox(width: context.isMobile ? 4 : 8),

          Text(
            '${_formatTime(state.currentTime)} / ${_formatTime(state.videoDuration)}',
            style: TextStyle(
              fontSize: context.isMobile ? 10 : 13,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          SizedBox(width: context.isMobile ? 4 : 16),

          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: context.isMobile ? 2 : 4,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: context.isMobile ? 6 : 8,
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius: context.isMobile ? 12 : 24,
                ),
              ),
              child: Slider(
                value: state.currentTime,
                min: 0,
                max: state.videoDuration,
                onChanged: (value) {
                  ref.read(canvasProvider.notifier).seekTo(value);
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),
          ),

            SizedBox(width: context.isMobile ? 4 : 16),
            const Icon(Icons.schedule, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            DropdownButton<double>(
              value: state.videoDuration,
              underline: const SizedBox(),
              items: [5.0, 10.0, 15.0, 30.0].map((duration) {
                return DropdownMenuItem(
                  value: duration,
                  child: Text(
                    '${duration.toInt()}s',
                    style: TextStyle(fontSize: context.isMobile ? 10 : 13),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(canvasProvider.notifier).setVideoDuration(value);
                }
              },
            ),
          ],
      ),
    );
  }

  Widget _buildTimeline(CanvasState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Icon tracks
          ...state.icons.asMap().entries.map((entry) {
            return _TimelineTrack(
              key: ValueKey('icon_${entry.value.id}'),
              id: entry.value.id,
              label: entry.value.type.name,
              icon: entry.value.type.icon,
              color: entry.value.type.color,
              startTime: entry.value.startTime,
              endTime: entry.value.endTime,
              variation: entry.value.selectedVariation,
              trackIndex: entry.key,
              videoDuration: state.videoDuration,
              currentTime: state.currentTime,
              isSelected: state.selectedIconId == entry.value.id,
              isIcon: true,
              onTap: () {
                ref.read(canvasProvider.notifier).selectIcon(entry.value.id);
              },
              onDragStart: (details) {
                setState(() {
                  _draggingId = entry.value.id;
                  _dragStartDx = details.localPosition.dx;
                  _initialStartTime = entry.value.startTime;
                  _initialEndTime = entry.value.endTime;
                  _isIcon = true;
                });
              },
              onDragUpdate: (details) {
                if (_draggingId != entry.value.id) return;

                final pixelsPerSecond =
                    MediaQuery.of(context).size.width / state.videoDuration;

                final dx = details.localPosition.dx - _dragStartDx!;
                final deltaTime = dx / pixelsPerSecond;

                final duration = _initialEndTime! - _initialStartTime!;
                final newStart = (_initialStartTime! + deltaTime).clamp(
                  0.0,
                  state.videoDuration - duration,
                );

                ref
                    .read(canvasProvider.notifier)
                    .updateIconTimeline(
                      entry.value.id,
                      startTime: newStart,
                      endTime: newStart + duration,
                    );
              },
              onDragEnd: () {
                setState(() {
                  _draggingId = null;
                  _dragStartDx = null;
                  _isIcon = true;
                });
              },
              onResizeStart: (isStart, details) {
                setState(() {
                  _resizingId = entry.value.id;
                  _resizingStart = isStart;
                  _dragStartDx = details.localPosition.dx;
                  _initialStartTime = entry.value.startTime;
                  _initialEndTime = entry.value.endTime;
                  _isIcon = true;
                });
              },
              onResizeUpdate: (details) {
                if (_resizingId != entry.value.id) return;

                final pixelsPerSecond =
                    MediaQuery.of(context).size.width / state.videoDuration;

                final dx = details.localPosition.dx - _dragStartDx!;
                final deltaTime = dx / pixelsPerSecond;

                if (_resizingStart) {
                  final newStart = (_initialStartTime! + deltaTime).clamp(
                    0.0,
                    _initialEndTime! - 0.5,
                  );

                  ref
                      .read(canvasProvider.notifier)
                      .updateIconTimeline(entry.value.id, startTime: newStart);
                } else {
                  final newEnd = (_initialEndTime! + deltaTime).clamp(
                    _initialStartTime! + 0.5,
                    state.videoDuration,
                  );

                  ref
                      .read(canvasProvider.notifier)
                      .updateIconTimeline(entry.value.id, endTime: newEnd);
                }
              },
              onResizeEnd: () {
                setState(() {
                  _resizingId = null;
                  _isIcon = true;
                });
              },
            );
          }),

          // Sketch tracks
          ...state.sketches.asMap().entries.map((entry) {
            return _TimelineTrack(
              key: ValueKey('sketch_${entry.value.id}'),
              id: entry.value.id,
              label: 'Sketch',
              icon: Icons.draw,
              color: AppTheme.primaryColor,
              startTime: entry.value.startTime,
              endTime: entry.value.endTime == double.infinity
                  ? state.videoDuration
                  : entry.value.endTime,
              variation: '${entry.value.points.length} points',
              trackIndex: state.icons.length + entry.key,
              videoDuration: state.videoDuration,
              currentTime: state.currentTime,
              isSelected: state.selectedSketchId == entry.value.id,
              isIcon: false,
              onTap: () {
                ref.read(canvasProvider.notifier).selectSketch(entry.value.id);
              },
              onDragStart: (details) {
                setState(() {
                  _draggingId = entry.value.id;
                  _dragStartDx = details.localPosition.dx;
                  _initialStartTime = entry.value.startTime;
                  _initialEndTime = entry.value.endTime;
                  _isIcon = false;
                });
              },
              onDragUpdate: (details) {
                if (_draggingId == entry.value.id && !_isIcon) {
                  if (_draggingId != entry.value.id) return;

                  final pixelsPerSecond =
                      MediaQuery.of(context).size.width / state.videoDuration;

                  final dx = details.localPosition.dx - _dragStartDx!;
                  final deltaTime = dx / pixelsPerSecond;

                  final duration = _initialEndTime! - _initialStartTime!;
                  final newStart = (_initialStartTime! + deltaTime).clamp(
                    0.0,
                    state.videoDuration - duration,
                  );
                  final newEnd = (newStart + duration).clamp(
                    newStart + 0.5,
                    state.videoDuration,
                  );

                  ref
                      .read(canvasProvider.notifier)
                      .updateSketchTimeline(
                        entry.value.id,
                        startTime: newStart,
                        endTime: newEnd,
                      );
                }
              },
              onDragEnd: () {
                setState(() {
                  _draggingId = null;
                  _isIcon = false;
                });
              },
              onResizeStart: (isStart, details) {
                setState(() {
                  _resizingId = entry.value.id;
                  _resizingStart = isStart;
                  _dragStartDx = details.localPosition.dx;
                  _initialStartTime = entry.value.startTime;
                  _initialEndTime = entry.value.endTime;
                  _isIcon = false;
                });
              },
              onResizeUpdate: (details) {
                if (_resizingId == entry.value.id && !_isIcon) {
                  final pixelsPerSecond =
                      MediaQuery.of(context).size.width / state.videoDuration;

                  final dx = details.localPosition.dx - _dragStartDx!;
                  final deltaTime = dx / pixelsPerSecond;

                  if (_resizingStart) {
                    final newStart = (_initialStartTime! + deltaTime).clamp(
                      0.0,
                      _initialEndTime! - 0.5,
                    );

                    ref
                        .read(canvasProvider.notifier)
                        .updateSketchTimeline(
                          entry.value.id,
                          startTime: newStart,
                        );
                  } else {
                    final newEnd = (_initialEndTime! + deltaTime).clamp(
                      _initialStartTime! + 0.5,
                      state.videoDuration,
                    );

                    ref
                        .read(canvasProvider.notifier)
                        .updateSketchTimeline(entry.value.id, endTime: newEnd);
                  }
                }
              },
              onResizeEnd: () {
                setState(() {
                  _resizingId = null;
                  _isIcon = false;
                });
              },
            );
          }),

          SizedBox(height: context.isMobile ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildTimeRuler(CanvasState state) {
    return Container(
      height: context.isMobile ? 24 : 30,
      padding: EdgeInsets.symmetric(horizontal: context.isMobile ? 8 : 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final pixelsPerSecond = width / state.videoDuration;

          return Stack(
            children: [
              CustomPaint(
                size: Size(width, context.isMobile ? 24 : 30),
                painter: _TimeRulerPainter(
                  duration: state.videoDuration,
                  pixelsPerSecond: pixelsPerSecond,
                  isMobile: context.isMobile,
                ),
              ),

              Positioned(
                left: state.currentTime * pixelsPerSecond,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: AppTheme.primaryColor,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.primaryColor,
                      size: context.isMobile ? 16 : 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    final ms = ((seconds % 1) * 10).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}.${ms}';
  }
}

class _TimelineTrack extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final double startTime;
  final double endTime;
  final String? variation;
  final int trackIndex;
  final double videoDuration;
  final double currentTime;
  final bool isSelected;
  final bool isIcon;
  final VoidCallback onTap;
  final Function(DragStartDetails) onDragStart;
  final Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onDragEnd;
  final Function(bool isStart, DragStartDetails) onResizeStart;
  final Function(DragUpdateDetails) onResizeUpdate;
  final VoidCallback onResizeEnd;

  const _TimelineTrack({
    required Key key,
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.startTime,
    required this.endTime,
    this.variation,
    required this.trackIndex,
    required this.videoDuration,
    required this.currentTime,
    required this.isSelected,
    required this.isIcon,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.isMobile ? 40 : 60,
      decoration: BoxDecoration(
        color: trackIndex.isEven
            ? AppTheme.backgroundColor
            : AppTheme.surfaceColor,
        border: const Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 8 : 12,
        vertical: context.isMobile ? 3 : 8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final pixelsPerSecond = width / videoDuration;

          final left = startTime * pixelsPerSecond;
          final trackWidth = (endTime - startTime) * pixelsPerSecond;

          return Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: 0.5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: context.isMobile ? 12 : 16,
                        color: color,
                      ),
                      SizedBox(width: context.isMobile ? 4 : 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: context.isMobile ? 10 : 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: left,
                width: trackWidth,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onTap,
                  onPanStart: onDragStart,
                  onPanUpdate: onDragUpdate,
                  onPanEnd: (_) => onDragEnd(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : color,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.isMobile ? 4 : 6,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icon,
                                size: context.isMobile ? 10 : 14,
                                color: color,
                              ),
                              SizedBox(width: context.isMobile ? 3 : 4),
                              Expanded(
                                child: Text(
                                  variation ?? label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: context.isMobile ? 9 : 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Left resize
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onPanStart: (d) => onResizeStart(true, d),
                            onPanUpdate: onResizeUpdate,
                            onPanEnd: (_) => onResizeEnd(),
                            child: Container(
                              width: context.isMobile ? 6 : 8,
                              color: Colors.transparent,
                              child: Center(
                                child: Container(width: 2, color: color),
                              ),
                            ),
                          ),
                        ),

                        // Right resize
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onPanStart: (d) => onResizeStart(false, d),
                            onPanUpdate: onResizeUpdate,
                            onPanEnd: (_) => onResizeEnd(),
                            child: Container(
                              width: context.isMobile ? 6 : 8,
                              color: Colors.transparent,
                              child: Center(
                                child: Container(width: 2, color: color),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimeRulerPainter extends CustomPainter {
  final double duration;
  final double pixelsPerSecond;
  final bool isMobile;

  _TimeRulerPainter({
    required this.duration,
    required this.pixelsPerSecond,
    required this.isMobile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= duration; i++) {
      final x = i * pixelsPerSecond;

      canvas.drawLine(
        Offset(x, size.height - (isMobile ? 8 : 10)),
        Offset(x, size.height),
        paint,
      );

      if (i % 5 == 0 || i == duration.toInt()) {
        textPainter.text = TextSpan(
          text: '${i}s',
          style: TextStyle(
            fontSize: isMobile ? 9 : 10,
            color: AppTheme.textSecondary,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, 2));
      }
    }
  }

  @override
  bool shouldRepaint(_TimeRulerPainter oldDelegate) =>
      duration != oldDelegate.duration ||
      pixelsPerSecond != oldDelegate.pixelsPerSecond ||
      isMobile != oldDelegate.isMobile;
}
