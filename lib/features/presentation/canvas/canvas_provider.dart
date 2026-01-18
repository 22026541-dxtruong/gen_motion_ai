import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gen_motion_ai/features/presentation/canvas/models.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// Canvas State Notifier
class CanvasNotifier extends StateNotifier<CanvasState> {
  Timer? _playbackTimer;
  
  CanvasNotifier() : super(CanvasState());

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  // Switch between Image/Video mode
  void setMode(GenerationMode mode) {
    state = state.copyWith(
      mode: mode,
      isPlaying: false,
      currentTime: 0.0,
    );
    _playbackTimer?.cancel();
  }

  // Canvas view controls
  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.25, 4.0));
  }

  void setPan(Offset pan) {
    state = state.copyWith(pan: pan);
  }

  void resetView() {
    state = state.copyWith(zoom: 1.0, pan: Offset.zero);
  }

  void toggleTimeline() {
    state = state.copyWith(showTimeline: !state.showTimeline);
  }

  // Add icon to canvas
  void addIcon(SmartIconType iconType, Offset position) {
    final newIcon = CanvasIcon(
      id: _uuid.v4(),
      type: iconType,
      position: position,
      size: 80,
      startTime: state.mode == GenerationMode.video ? state.currentTime : 0,
      endTime: state.mode == GenerationMode.video 
        ? state.currentTime + 3.0 
        : state.videoDuration,
    );
    
    state = state.copyWith(
      icons: [...state.icons, newIcon],
      selectedIconId: newIcon.id,
      selectedSketchId: null,
    );
  }

  // Update icon position - KEEP SELECTION
  void updateIconPosition(String id, Offset position) {
    final updatedIcons = state.icons.map((icon) {
      return icon.id == id ? icon.copyWith(position: position) : icon;
    }).toList();
    
    state = state.copyWith(
      icons: updatedIcons,
      selectedIconId: id, // KEEP SELECTION!
    );
  }

  // Update icon size - KEEP SELECTION
  void updateIconSize(String id, double size) {
    final updatedIcons = state.icons.map((icon) {
      return icon.id == id ? icon.copyWith(size: size) : icon;
    }).toList();
    
    state = state.copyWith(
      icons: updatedIcons,
      selectedIconId: id, // KEEP SELECTION!
    );
  }

  // Update icon rotation - KEEP SELECTION
  void updateIconRotation(String id, double rotation) {
    final updatedIcons = state.icons.map((icon) {
      return icon.id == id ? icon.copyWith(rotation: rotation) : icon;
    }).toList();
    
    state = state.copyWith(
      icons: updatedIcons,
      selectedIconId: id, // KEEP SELECTION!
    );
  }

  // Select variation - KEEP SELECTION
  void selectVariation(String id, String variation) {
    final updatedIcons = state.icons.map((icon) {
      return icon.id == id ? icon.copyWith(selectedVariation: variation) : icon;
    }).toList();
    
    state = state.copyWith(
      icons: updatedIcons,
      selectedIconId: id, // KEEP SELECTION!
    );
  }

  // Update timeline - KEEP SELECTION
  void updateIconTimeline(String id, {double? startTime, double? endTime}) {
    final updatedIcons = state.icons.map((icon) {
      if (icon.id == id) {
        return icon.copyWith(
          startTime: startTime ?? icon.startTime,
          endTime: endTime ?? icon.endTime,
        );
      }
      return icon;
    }).toList();
    
    state = state.copyWith(
      icons: updatedIcons,
      selectedIconId: id, // KEEP SELECTION!
    );
  }

  // Update animation - KEEP SELECTION
  void updateIconAnimation(String id, String animation) {
    final updatedIcons = state.icons.map((icon) {
      return icon.id == id ? icon.copyWith(animation: animation) : icon;
    }).toList();
    
    state = state.copyWith(
      icons: updatedIcons,
      selectedIconId: id, // KEEP SELECTION!
    );
  }

  // Keyframe management - KEEP SELECTION
  void addKeyframe(String iconId, double time) {
    final icon = state.icons.firstWhere((i) => i.id == iconId);
    
    final newKeyframe = Keyframe(
      time: time,
      position: icon.position,
      size: icon.size,
      rotation: icon.rotation,
      opacity: icon.opacity,
    );
    
    final keyframes = [...icon.keyframes, newKeyframe]
      ..sort((a, b) => a.time.compareTo(b.time));
    
    final updatedIcons = state.icons.map((i) {
      return i.id == iconId ? i.copyWith(keyframes: keyframes) : i;
    }).toList();
    
    state = state.copyWith(
      icons: updatedIcons,
      selectedIconId: iconId, // KEEP SELECTION!
    );
  }

  void removeKeyframe(String iconId, double time) {
    final icon = state.icons.firstWhere((i) => i.id == iconId);
    
    final keyframes = icon.keyframes.where((kf) => kf.time != time).toList();
    
    final updatedIcons = state.icons.map((i) {
      return i.id == iconId ? i.copyWith(keyframes: keyframes) : i;
    }).toList();
    
    state = state.copyWith(
      icons: updatedIcons,
      selectedIconId: iconId, // KEEP SELECTION!
    );
  }

  void updateKeyframe(String iconId, double oldTime, Keyframe newKeyframe) {
    final icon = state.icons.firstWhere((i) => i.id == iconId);
    
    final keyframes = icon.keyframes.map((kf) {
      return kf.time == oldTime ? newKeyframe : kf;
    }).toList()..sort((a, b) => a.time.compareTo(b.time));
    
    final updatedIcons = state.icons.map((i) {
      return i.id == iconId ? i.copyWith(keyframes: keyframes) : i;
    }).toList();
    
    state = state.copyWith(
      icons: updatedIcons,
      selectedIconId: iconId, // KEEP SELECTION!
    );
  }

  // Select icon or sketch
  void selectIcon(String? id) {
    state = state.copyWith(
      selectedIconId: id,
      selectedSketchId: id == null ? state.selectedSketchId : null,
    );
  }

  void selectSketch(String? id) {
    state = state.copyWith(
      selectedSketchId: id,
      selectedIconId: id == null ? state.selectedIconId : null,
    );
  }

  // Delete icon
  void deleteIcon(String id) {
    final updatedIcons = state.icons.where((icon) => icon.id != id).toList();
    state = state.copyWith(
      icons: updatedIcons,
      selectedIconId: state.selectedIconId == id ? null : state.selectedIconId,
    );
  }

  // Delete sketch
  void deleteSketch(String id) {
    final updatedSketches = state.sketches.where((s) => s.id != id).toList();
    state = state.copyWith(
      sketches: updatedSketches,
      selectedSketchId: state.selectedSketchId == id ? null : state.selectedSketchId,
    );
  }

  // Clear canvas
  void clearCanvas() {
    _playbackTimer?.cancel();
    state = CanvasState(mode: state.mode, showTimeline: state.showTimeline);
  }

  // Toggle drawing mode
  void toggleDrawingMode() {
    state = state.copyWith(
      isDrawingMode: !state.isDrawingMode,
      selectedIconId: null,
      selectedSketchId: null,
    );
  }

  // Sketch management
  void addDrawingPoint(Offset point, Paint paint) {
    final newPoint = DrawingPoint(
      offset: point,
      paint: paint,
      timestamp: state.currentTime,
    );
    state = state.copyWith(
      currentSketchPoints: [...state.currentSketchPoints, newPoint],
    );
  }

  void finishSketch() {
    if (state.currentSketchPoints.isEmpty) return;
    
    final newSketch = SketchStroke(
      id: _uuid.v4(),
      points: state.currentSketchPoints,
      startTime: state.mode == GenerationMode.video ? state.currentTime : 0,
      endTime: state.mode == GenerationMode.video 
        ? state.currentTime + 5.0 
        : double.infinity,
      color: Colors.black,
      strokeWidth: 3,
    );
    
    state = state.copyWith(
      sketches: [...state.sketches, newSketch],
      currentSketchPoints: [],
      selectedSketchId: newSketch.id,
    );
  }

  void clearCurrentSketch() {
    state = state.copyWith(currentSketchPoints: []);
  }

  void updateSketchTimeline(String id, {double? startTime, double? endTime}) {
    final updatedSketches = state.sketches.map((sketch) {
      if (sketch.id == id) {
        return sketch.copyWith(
          startTime: startTime ?? sketch.startTime,
          endTime: endTime ?? sketch.endTime,
        );
      }
      return sketch;
    }).toList();
    
    state = state.copyWith(
      sketches: updatedSketches,
      selectedSketchId: id, // KEEP SELECTION!
    );
  }

  // Video playback controls
  void playVideo() {
    if (state.mode != GenerationMode.video) return;
    
    state = state.copyWith(isPlaying: true);
    
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (state.currentTime >= state.videoDuration) {
        stopVideo();
        state = state.copyWith(currentTime: 0.0);
      } else {
        state = state.copyWith(currentTime: state.currentTime + 0.1);
      }
    });
  }

  void pauseVideo() {
    _playbackTimer?.cancel();
    state = state.copyWith(isPlaying: false);
  }

  void stopVideo() {
    _playbackTimer?.cancel();
    state = state.copyWith(isPlaying: false, currentTime: 0.0);
  }

  void seekTo(double time) {
    state = state.copyWith(
      currentTime: time.clamp(0.0, state.videoDuration),
    );
  }

  void setVideoDuration(double duration) {
    state = state.copyWith(videoDuration: duration);
  }

  // Generate prompt
  String generatePrompt() {
    if (state.icons.isEmpty && state.sketches.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    
    if (state.mode == GenerationMode.video) {
      buffer.write('A ${state.videoDuration.toStringAsFixed(0)}-second video showing ');
      
      final sortedIcons = [...state.icons]..sort((a, b) => a.startTime.compareTo(b.startTime));
      for (var i = 0; i < sortedIcons.length; i++) {
        final icon = sortedIcons[i];
        final variation = icon.selectedVariation ?? icon.type.variations.first;
        
        if (i > 0) buffer.write(', then ');
        buffer.write('$variation at ${icon.startTime.toStringAsFixed(1)}s');
        
        if (icon.keyframes.isNotEmpty) {
          buffer.write(' with animated movement');
        }
      }
      
      if (state.sketches.isNotEmpty) {
        buffer.write(', with hand-drawn elements');
      }
    } else {
      buffer.write('A composition with ');
      
      final parts = <String>[];
      
      for (final icon in state.icons) {
        final variation = icon.selectedVariation ?? icon.type.variations.first;
        parts.add(variation);
      }
      
      if (state.sketches.isNotEmpty) {
        parts.add('hand-drawn sketch elements');
      }
      
      buffer.write(parts.join(', '));
    }

    buffer.write('. Professional quality, detailed');
    return buffer.toString();
  }
}

// Providers
final canvasProvider = StateNotifierProvider<CanvasNotifier, CanvasState>((ref) {
  return CanvasNotifier();
});

final selectedIconProvider = Provider<CanvasIcon?>((ref) {
  final state = ref.watch(canvasProvider);
  if (state.selectedIconId == null) return null;
  
  try {
    return state.icons.firstWhere((icon) => icon.id == state.selectedIconId);
  } catch (e) {
    return null;
  }
});

final selectedSketchProvider = Provider<SketchStroke?>((ref) {
  final state = ref.watch(canvasProvider);
  if (state.selectedSketchId == null) return null;
  
  try {
    return state.sketches.firstWhere((s) => s.id == state.selectedSketchId);
  } catch (e) {
    return null;
  }
});

final visibleIconsProvider = Provider<List<CanvasIcon>>((ref) {
  final state = ref.watch(canvasProvider);
  if (state.mode == GenerationMode.image) {
    return state.icons;
  }
  
  return state.getVisibleIconsAt(state.currentTime).map((icon) {
    return icon.interpolateAt(state.currentTime);
  }).toList();
});

final visibleSketchesProvider = Provider<List<SketchStroke>>((ref) {
  final state = ref.watch(canvasProvider);
  return state.getVisibleSketchesAt(state.currentTime);
});
