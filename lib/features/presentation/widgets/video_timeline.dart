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

  String? _draggingIconId;
  String? _resizingIconId;
  bool _resizingStart = false;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);

    if (canvasState.mode != GenerationMode.video) {
      return const SizedBox.shrink();
    }

    return Container(
      height: context.isMobile ? 200 : 250,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Column(
        children: [
          // Playback controls
          _buildPlaybackControls(canvasState),

          const Divider(height: 1, color: AppTheme.borderColor),

          // Timeline
          Expanded(child: _buildTimeline(canvasState)),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(CanvasState state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 12 : 16,
        vertical: context.isMobile ? 8 : 12,
      ),
      child: Row(
        children: [
          // Play/Pause button
          IconButton(
            icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (state.isPlaying) {
                ref.read(canvasProvider.notifier).pauseVideo();
              } else {
                ref.read(canvasProvider.notifier).playVideo();
              }
            },
            iconSize: context.isMobile ? 24 : 28,
            color: AppTheme.primaryColor,
          ),

          // Stop button
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              ref.read(canvasProvider.notifier).stopVideo();
            },
            iconSize: context.isMobile ? 24 : 28,
          ),

          const SizedBox(width: 8),

          // Time display
          Text(
            '${_formatTime(state.currentTime)} / ${_formatTime(state.videoDuration)}',
            style: TextStyle(
              fontSize: context.isMobile ? 12 : 13,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(width: 16),

          // Timeline slider
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: context.isMobile ? 3 : 4,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: context.isMobile ? 6 : 8,
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

          const SizedBox(width: 16),

          // Duration selector
          if (!context.isMobile)
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                DropdownButton<double>(
                  value: state.videoDuration,
                  underline: const SizedBox(),
                  items: [5.0, 10.0, 15.0, 30.0].map((duration) {
                    return DropdownMenuItem(
                      value: duration,
                      child: Text(
                        '${duration.toInt()}s',
                        style: const TextStyle(fontSize: 13),
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
        ],
      ),
    );
  }

  Widget _buildTimeline(CanvasState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Time ruler
          _buildTimeRuler(state),

          const Divider(height: 1, color: AppTheme.borderColor),

          // Icon tracks
          ...state.icons.asMap().entries.map((entry) {
            return _TimelineTrack(
              icon: entry.value,
              trackIndex: entry.key,
              videoDuration: state.videoDuration,
              currentTime: state.currentTime,
              isSelected: state.selectedIconId == entry.value.id,
              onTap: () {
                ref.read(canvasProvider.notifier).selectIcon(entry.value.id);
              },
              onDragStart: (details) {
                setState(() {
                  _draggingIconId = entry.value.id;
                  _dragStartDx = details.localPosition.dx;
                  _initialStartTime = entry.value.startTime;
                  _initialEndTime = entry.value.endTime;
                });
              },
              onDragUpdate: (details) {
                if (_draggingIconId != entry.value.id) return;

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
                  _draggingIconId = null;
                  _dragStartDx = null;
                });
              },
              onResizeStart: (isStart, details) {
                setState(() {
                  _resizingIconId = entry.value.id;
                  _resizingStart = isStart;
                  _dragStartDx = details.localPosition.dx;
                  _initialStartTime = entry.value.startTime;
                  _initialEndTime = entry.value.endTime;
                });
              },
              onResizeUpdate: (details) {
                if (_resizingIconId != entry.value.id) return;

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
                  _resizingIconId = null;
                });
              },
            );
          }),

          // Add track button
          Padding(
            padding: EdgeInsets.all(context.isMobile ? 8 : 12),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                'Add Icon to Timeline',
                style: TextStyle(fontSize: context.isMobile ? 12 : 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRuler(CanvasState state) {
    return Container(
      height: 30,
      padding: EdgeInsets.symmetric(horizontal: context.isMobile ? 8 : 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final pixelsPerSecond = width / state.videoDuration;

          return Stack(
            children: [
              // Time markers
              CustomPaint(
                size: Size(width, 30),
                painter: _TimeRulerPainter(
                  duration: state.videoDuration,
                  pixelsPerSecond: pixelsPerSecond,
                ),
              ),

              // Playhead
              Positioned(
                left: state.currentTime * pixelsPerSecond,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: AppTheme.primaryColor,
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.primaryColor,
                      size: 20,
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

// Timeline Track Widget
class _TimelineTrack extends StatelessWidget {
  final CanvasIcon icon;
  final int trackIndex;
  final double videoDuration;
  final double currentTime;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(DragStartDetails) onDragStart;
  final Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onDragEnd;
  final Function(bool isStart, DragStartDetails) onResizeStart;
  final Function(DragUpdateDetails) onResizeUpdate;
  final VoidCallback onResizeEnd;

  const _TimelineTrack({
    required this.icon,
    required this.trackIndex,
    required this.videoDuration,
    required this.currentTime,
    required this.isSelected,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.isMobile ? 50 : 60,
      decoration: BoxDecoration(
        color: trackIndex.isEven
            ? AppTheme.backgroundColor
            : AppTheme.surfaceColor,
        border: const Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 8 : 12,
        vertical: context.isMobile ? 4 : 8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final pixelsPerSecond = width / videoDuration;

          final left = icon.startTime * pixelsPerSecond;
          final trackWidth = (icon.endTime - icon.startTime) * pixelsPerSecond;

          return Stack(
            children: [
              // Track label
              Align(
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: 0.5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon.type.icon, size: 16, color: icon.type.color),
                      const SizedBox(width: 6),
                      Text(
                        icon.type.name,
                        style: TextStyle(
                          fontSize: context.isMobile ? 11 : 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Icon timeline block
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
                      color: icon.type.color.withOpacity(0.3),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : icon.type.color,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        // Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              Icon(
                                icon.type.icon,
                                size: 14,
                                color: icon.type.color,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  icon.selectedVariation ?? icon.type.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: context.isMobile ? 10 : 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Left resize handle
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onPanStart: (d) => onResizeStart(true, d),
                            onPanUpdate: onResizeUpdate,
                            onPanEnd: (_) => onResizeEnd(),
                            child: Container(
                              width: 8,
                              color: Colors.transparent,
                              child: Center(
                                child: Container(
                                  width: 3,
                                  color: icon.type.color,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Right resize handle
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onPanStart: (d) => onResizeStart(false, d),
                            onPanUpdate: onResizeUpdate,
                            onPanEnd: (_) => onResizeEnd(),
                            child: Container(
                              width: 8,
                              color: Colors.transparent,
                              child: Center(
                                child: Container(
                                  width: 3,
                                  color: icon.type.color,
                                ),
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

// Time Ruler Painter
class _TimeRulerPainter extends CustomPainter {
  final double duration;
  final double pixelsPerSecond;

  _TimeRulerPainter({required this.duration, required this.pixelsPerSecond});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw time markers every second
    for (var i = 0; i <= duration; i++) {
      final x = i * pixelsPerSecond;

      // Draw tick
      canvas.drawLine(
        Offset(x, size.height - 10),
        Offset(x, size.height),
        paint,
      );

      // Draw time label every 5 seconds or at start/end
      if (i % 5 == 0 || i == duration.toInt()) {
        textPainter.text = TextSpan(
          text: '${i}s',
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, 2));
      }
    }
  }

  @override
  bool shouldRepaint(_TimeRulerPainter oldDelegate) =>
      duration != oldDelegate.duration ||
      pixelsPerSecond != oldDelegate.pixelsPerSecond;
}
