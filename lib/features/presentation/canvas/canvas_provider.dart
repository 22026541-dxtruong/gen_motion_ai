import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gen_motion_ai/features/presentation/canvas/models.dart' as models;
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class CanvasNotifier extends StateNotifier<models.CanvasState> {
  Timer? _playbackTimer;
  
  CanvasNotifier() : super(models.CanvasState());

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void setMode(models.GenerationMode mode) {
    state = state.copyWith(mode: mode, isPlaying: false, currentTime: 0.0);
    _playbackTimer?.cancel();
  }

  void setAspectRatio(models.AspectRatio ratio) {
    final oldRatio = state.aspectRatio.ratio;
    final newRatio = ratio.ratio;
    
    if (oldRatio == newRatio) return;
    
    // Logic to scale content to fit new aspect ratio
    // Assuming logical width is fixed (e.g. 1000.0)
    const double logicalWidth = 1000.0;
    final oldHeight = logicalWidth / oldRatio;
    final newHeight = logicalWidth / newRatio;
    
    // Center offset adjustment
    final oldCenterY = oldHeight / 2;
    final newCenterY = newHeight / 2;
    final dyDelta = newCenterY - oldCenterY;
    
    final updatedIcons = state.icons.map((icon) {
      // Adjust position relative to new center
      return icon.copyWith(
        position: Offset(icon.position.dx, icon.position.dy + dyDelta),
      );
    }).toList();

    final updatedSketches = state.sketches.map((sketch) {
      return sketch.copyWith(
        position: Offset(sketch.position.dx, sketch.position.dy + dyDelta),
      );
    }).toList();

    state = state.copyWith(
      aspectRatio: ratio,
      icons: updatedIcons,
      sketches: updatedSketches,
    );
  }

  void toggleTimeline() {
    state = state.copyWith(showTimeline: !state.showTimeline);
  }

  void addIcon(models.SmartIconType iconType, Offset position) {
    final newIcon = models.CanvasIcon(
      id: _uuid.v4(),
      type: iconType,
      position: position,
      size: 80,
      startTime: state.mode == models.GenerationMode.video ? state.currentTime : 0,
      endTime: state.mode == models.GenerationMode.video 
        ? state.currentTime + 3.0 
        : state.videoDuration,
    );
    
    state = state.copyWith(
      icons: [...state.icons, newIcon],
      selectedIconId: newIcon.id,
      selectedSketchId: null,
    );
  }

  void addUserImages(List<String> paths) {
    final newImages = paths.map((path) {
      return models.UserImage(
        id: _uuid.v4(),
        path: path,
        position: const Offset(0, 0), // Center or cascade
        size: const Size(200, 200), // Default size
        rotation: 0,
        opacity: 1.0,
        startTime: state.mode == models.GenerationMode.video ? state.currentTime : 0,
        endTime: state.mode == models.GenerationMode.video 
          ? state.currentTime + 3.0 
          : state.videoDuration,
      );
    }).toList();

    state = state.copyWith(
      userImages: [...state.userImages, ...newImages],
      selectedUserImageId: newImages.isNotEmpty ? newImages.last.id : null,
      selectedIconId: null,
      selectedSketchId: null,
    );
  }

  void addUserVideo(String path) {
    final newVideo = models.UserVideo(
      id: _uuid.v4(),
      path: path,
      position: const Offset(0, 0),
      size: const Size(320, 180),
      startTime: state.currentTime,
      duration: 5.0,
      originalDuration: 20.0, // Giả lập
    );
    state = state.copyWith(
      userVideos: [...state.userVideos, newVideo],
      selectedUserVideoId: newVideo.id,
      selectedIconId: null,
      selectedSketchId: null,
      selectedUserImageId: null,
    );
  }

  void updateIconPosition(String id, Offset position) {
    final updatedIcons = state.icons.map((icon) {
      return icon.id == id ? icon.copyWith(position: position) : icon;
    }).toList();
    
    state = state.copyWith(icons: updatedIcons, selectedIconId: id);
  }

  void updateIconSize(String id, double size) {
    final updatedIcons = state.icons.map((icon) {
      return icon.id == id ? icon.copyWith(size: size) : icon;
    }).toList();
    
    state = state.copyWith(icons: updatedIcons, selectedIconId: id);
  }

  void updateIconRotation(String id, double rotation) {
    final updatedIcons = state.icons.map((icon) {
      return icon.id == id ? icon.copyWith(rotation: rotation) : icon;
    }).toList();
    
    state = state.copyWith(icons: updatedIcons, selectedIconId: id);
  }

  void selectVariation(String id, String variation) {
    final updatedIcons = state.icons.map((icon) {
      return icon.id == id ? icon.copyWith(selectedVariation: variation) : icon;
    }).toList();
    
    state = state.copyWith(icons: updatedIcons, selectedIconId: id);
  }

  void updateIconTimeline(String id, {double? startTime, double? endTime}) {
    final updatedIcons = state.icons.map((icon) {
      if (icon.id == id) {
        return icon.copyWith(startTime: startTime ?? icon.startTime, endTime: endTime ?? icon.endTime);
      }
      return icon;
    }).toList();
    
    state = state.copyWith(icons: updatedIcons, selectedIconId: id);
  }

  void updateIconAnimation(String id, String animation) {
    final updatedIcons = state.icons.map((icon) {
      return icon.id == id ? icon.copyWith(animation: animation) : icon;
    }).toList();
    
    state = state.copyWith(icons: updatedIcons, selectedIconId: id);
  }

  void addKeyframe(String iconId, double time) {
    final icon = state.icons.firstWhere((i) => i.id == iconId);
    final newKeyframe = models.Keyframe(
      time: time, position: icon.position, size: icon.size,
      rotation: icon.rotation, opacity: icon.opacity,
    );
    final keyframes = [...icon.keyframes, newKeyframe]..sort((a, b) => a.time.compareTo(b.time));
    final updatedIcons = state.icons.map((i) {
      return i.id == iconId ? i.copyWith(keyframes: keyframes) : i;
    }).toList();
    state = state.copyWith(icons: updatedIcons, selectedIconId: iconId);
  }

  void removeKeyframe(String iconId, double time) {
    final icon = state.icons.firstWhere((i) => i.id == iconId);
    final keyframes = icon.keyframes.where((kf) => kf.time != time).toList();
    final updatedIcons = state.icons.map((i) {
      return i.id == iconId ? i.copyWith(keyframes: keyframes) : i;
    }).toList();
    state = state.copyWith(icons: updatedIcons, selectedIconId: iconId);
  }

  void selectIcon(String? id) {
    state = state.copyWith(
      selectedIconId: id, 
      selectedSketchId: null,
      selectedUserImageId: null,
      selectedUserVideoId: null,
    );
  }

  void selectSketch(String? id) {
    state = state.copyWith(
      selectedSketchId: id, 
      selectedIconId: null,
      selectedUserImageId: null,
      selectedUserVideoId: null,
    );
  }

  void selectUserImage(String? id) {
    state = state.copyWith(
      selectedUserImageId: id,
      selectedIconId: null,
      selectedSketchId: null,
      selectedUserVideoId: null,
    );
  }

  void selectUserVideo(String? id) {
    state = state.copyWith(
      selectedUserVideoId: id,
      selectedIconId: null,
      selectedSketchId: null,
      selectedUserImageId: null,
    );
  }

  void deleteIcon(String id) {
    final updatedIcons = state.icons.where((icon) => icon.id != id).toList();
    state = state.copyWith(icons: updatedIcons, selectedIconId: state.selectedIconId == id ? null : state.selectedIconId);
  }

  void deleteSketch(String id) {
    final updatedSketches = state.sketches.where((s) => s.id != id).toList();
    state = state.copyWith(sketches: updatedSketches, selectedSketchId: state.selectedSketchId == id ? null : state.selectedSketchId);
  }

  void deleteUserImage(String id) {
    final updatedImages = state.userImages.where((img) => img.id != id).toList();
    state = state.copyWith(userImages: updatedImages, selectedUserImageId: state.selectedUserImageId == id ? null : state.selectedUserImageId);
  }

  void deleteUserVideo(String id) {
    final updatedVideos = state.userVideos.where((v) => v.id != id).toList();
    state = state.copyWith(userVideos: updatedVideos, selectedUserVideoId: state.selectedUserVideoId == id ? null : state.selectedUserVideoId);
  }

  void clearCanvas() {
    _playbackTimer?.cancel();
    state = models.CanvasState(mode: state.mode, showTimeline: state.showTimeline, aspectRatio: state.aspectRatio);
  }

  void toggleDrawingMode() {
    state = state.copyWith(isDrawingMode: !state.isDrawingMode, selectedIconId: null, selectedSketchId: null, selectedUserImageId: null, selectedUserVideoId: null);
  }

  void addDrawingPoint(Offset point, Paint paint) {
    final newPoint = models.DrawingPoint(offset: point, paint: paint, timestamp: state.currentTime);
    state = state.copyWith(currentSketchPoints: [...state.currentSketchPoints, newPoint]);
  }

  void finishSketch() {
    if (state.currentSketchPoints.isEmpty) return;
    
    // Calculate bounds to normalize points
    double minX = state.currentSketchPoints.first.offset.dx;
    double maxX = minX;
    double minY = state.currentSketchPoints.first.offset.dy;
    double maxY = minY;

    for (var p in state.currentSketchPoints) {
      if (p.offset.dx < minX) minX = p.offset.dx;
      if (p.offset.dx > maxX) maxX = p.offset.dx;
      if (p.offset.dy < minY) minY = p.offset.dy;
      if (p.offset.dy > maxY) maxY = p.offset.dy;
    }

    final width = maxX - minX;
    final height = maxY - minY;
    final size = Size(width, height);
    final center = Offset(minX + width / 2, minY + height / 2);

    // Normalize points relative to center
    final relativePoints = state.currentSketchPoints.map((p) {
      return models.DrawingPoint(
        offset: p.offset - center,
        paint: p.paint,
        timestamp: p.timestamp,
      );
    }).toList();

    final newSketch = models.SketchStroke(
      id: _uuid.v4(),
      points: relativePoints,
      startTime: state.mode == models.GenerationMode.video ? state.currentTime : 0,
      endTime: state.mode == models.GenerationMode.video ? state.currentTime + 5.0 : double.infinity,
      color: Colors.black,
      strokeWidth: 3,
      position: center,
      size: size,
    );
    
    state = state.copyWith(sketches: [...state.sketches, newSketch], currentSketchPoints: [], selectedSketchId: newSketch.id);
  }

  void updateSketchTimeline(String id, {double? startTime, double? endTime}) {
    final updatedSketches = state.sketches.map((sketch) {
      if (sketch.id == id) {
        return sketch.copyWith(startTime: startTime ?? sketch.startTime, endTime: endTime ?? sketch.endTime);
      }
      return sketch;
    }).toList();
    state = state.copyWith(sketches: updatedSketches, selectedSketchId: id);
  }

  void updateSketchColor(String id, Color color) {
    final updatedSketches = state.sketches.map((sketch) {
      return sketch.id == id ? sketch.copyWith(color: color) : sketch;
    }).toList();
    state = state.copyWith(sketches: updatedSketches, selectedSketchId: id);
  }

  void updateSketchStrokeWidth(String id, double width) {
    final updatedSketches = state.sketches.map((sketch) {
      return sketch.id == id ? sketch.copyWith(strokeWidth: width) : sketch;
    }).toList();
    state = state.copyWith(sketches: updatedSketches, selectedSketchId: id);
  }

  void updateSketchPosition(String id, Offset position) {
    final updatedSketches = state.sketches.map((sketch) {
      return sketch.id == id ? sketch.copyWith(position: position) : sketch;
    }).toList();
    state = state.copyWith(sketches: updatedSketches, selectedSketchId: id);
  }

  void updateSketchRotation(String id, double rotation) {
    final updatedSketches = state.sketches.map((sketch) {
      return sketch.id == id ? sketch.copyWith(rotation: rotation) : sketch;
    }).toList();
    state = state.copyWith(sketches: updatedSketches, selectedSketchId: id);
  }

  void updateSketchScale(String id, double scale) {
    final updatedSketches = state.sketches.map((sketch) {
      return sketch.id == id ? sketch.copyWith(scale: scale) : sketch;
    }).toList();
    state = state.copyWith(sketches: updatedSketches, selectedSketchId: id);
  }

  void updateUserImagePosition(String id, Offset position) {
    final updatedImages = state.userImages.map((img) {
      return img.id == id ? img.copyWith(position: position) : img;
    }).toList();
    state = state.copyWith(userImages: updatedImages, selectedUserImageId: id);
  }

  void updateUserImageSize(String id, Size size) {
    final updatedImages = state.userImages.map((img) {
      return img.id == id ? img.copyWith(size: size) : img;
    }).toList();
    state = state.copyWith(userImages: updatedImages, selectedUserImageId: id);
  }

  void updateUserImageRotation(String id, double rotation) {
    final updatedImages = state.userImages.map((img) {
      return img.id == id ? img.copyWith(rotation: rotation) : img;
    }).toList();
    state = state.copyWith(userImages: updatedImages, selectedUserImageId: id);
  }

  void updateUserImageOpacity(String id, double opacity) {
    final updatedImages = state.userImages.map((img) {
      return img.id == id ? img.copyWith(opacity: opacity) : img;
    }).toList();
    state = state.copyWith(userImages: updatedImages, selectedUserImageId: id);
  }

  void updateUserImageTimeline(String id, {double? startTime, double? endTime}) {
    final updatedImages = state.userImages.map((img) {
      if (img.id == id) {
        return img.copyWith(startTime: startTime ?? img.startTime, endTime: endTime ?? img.endTime);
      }
      return img;
    }).toList();
    state = state.copyWith(userImages: updatedImages, selectedUserImageId: id);
  }

  void updateUserVideoTimeline(String id, {double? startTime}) {
    final updatedVideos = state.userVideos.map((v) {
      if (v.id == id) {
        return v.copyWith(startTime: startTime ?? v.startTime);
      }
      return v;
    }).toList();
    state = state.copyWith(userVideos: updatedVideos, selectedUserVideoId: id);
  }

  // --- Video Updates ---
  void updateUserVideoPosition(String id, Offset position) {
    final updatedVideos = state.userVideos.map((v) => v.id == id ? v.copyWith(position: position) : v).toList();
    state = state.copyWith(userVideos: updatedVideos, selectedUserVideoId: id);
  }

  void updateUserVideoSize(String id, Size size) {
    final updatedVideos = state.userVideos.map((v) => v.id == id ? v.copyWith(size: size) : v).toList();
    state = state.copyWith(userVideos: updatedVideos, selectedUserVideoId: id);
  }

  void updateUserVideoRotation(String id, double rotation) {
    final updatedVideos = state.userVideos.map((v) => v.id == id ? v.copyWith(rotation: rotation) : v).toList();
    state = state.copyWith(userVideos: updatedVideos, selectedUserVideoId: id);
  }

  void updateUserVideoVolume(String id, double volume) {
    final updatedVideos = state.userVideos.map((v) => v.id == id ? v.copyWith(volume: volume) : v).toList();
    state = state.copyWith(userVideos: updatedVideos, selectedUserVideoId: id);
  }

  void updateUserVideoSpeed(String id, double speed) {
    final updatedVideos = state.userVideos.map((v) {
      if (v.id == id) {
        // Calculate source duration (length of the clip in original video time)
        final sourceDuration = v.duration * v.playbackSpeed;
        // Calculate new timeline duration based on new speed
        final newDuration = sourceDuration / speed;
        
        return v.copyWith(playbackSpeed: speed, duration: newDuration);
      }
      return v;
    }).toList();
    state = state.copyWith(userVideos: updatedVideos, selectedUserVideoId: id);
  }

  void updateUserVideoTrim(String id, double start, double end) {
    final updatedVideos = state.userVideos.map((v) {
      if (v.id == id) {
        // Cập nhật trim và tính lại duration hiển thị
        final newDuration = (end - start) / v.playbackSpeed;
        return v.copyWith(trimStart: start, duration: newDuration);
      }
      return v;
    }).toList();
    state = state.copyWith(userVideos: updatedVideos, selectedUserVideoId: id);
  }

  void playVideo() {
    if (state.mode != models.GenerationMode.video) return;
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
    state = state.copyWith(currentTime: time.clamp(0.0, state.videoDuration));
  }

  void setVideoDuration(double duration) {
    state = state.copyWith(videoDuration: duration);
  }

  String generatePrompt() {
    if (state.icons.isEmpty && state.sketches.isEmpty) return '';
    final buffer = StringBuffer();
    if (state.mode == models.GenerationMode.video) {
      buffer.write('A ${state.videoDuration.toStringAsFixed(0)}-second video showing ');
      final sortedIcons = [...state.icons]..sort((a, b) => a.startTime.compareTo(b.startTime));
      for (var i = 0; i < sortedIcons.length; i++) {
        final icon = sortedIcons[i];
        final variation = icon.selectedVariation ?? icon.type.variations.first;
        if (i > 0) buffer.write(', then ');
        buffer.write('$variation at ${icon.startTime.toStringAsFixed(1)}s');
        if (icon.keyframes.isNotEmpty) buffer.write(' with animated movement');
      }
      if (state.userImages.isNotEmpty) {
        buffer.write(', with ${state.userImages.length} custom background images');
      }
      if (state.sketches.isNotEmpty) buffer.write(', with hand-drawn elements');
    } else {
      buffer.write('A composition with ');
      final parts = <String>[];
      for (final icon in state.icons) {
        final variation = icon.selectedVariation ?? icon.type.variations.first;
        parts.add(variation);
      }
      if (state.userImages.isNotEmpty) {
        parts.add('${state.userImages.length} custom images');
      }
      if (state.sketches.isNotEmpty) parts.add('hand-drawn sketch elements');
      buffer.write(parts.join(', '));
    }
    buffer.write('. Professional quality, detailed');
    return buffer.toString();
  }
}

final canvasProvider = StateNotifierProvider<CanvasNotifier, models.CanvasState>((ref) => CanvasNotifier());

final selectedIconProvider = Provider<models.CanvasIcon?>((ref) {
  final state = ref.watch(canvasProvider);
  if (state.selectedIconId == null) return null;
  try {
    return state.icons.firstWhere((icon) => icon.id == state.selectedIconId);
  } catch (e) {
    return null;
  }
});

final selectedSketchProvider = Provider<models.SketchStroke?>((ref) {
  final state = ref.watch(canvasProvider);
  if (state.selectedSketchId == null) return null;
  try {
    return state.sketches.firstWhere((s) => s.id == state.selectedSketchId);
  } catch (e) {
    return null;
  }
});

final visibleIconsProvider = Provider<List<models.CanvasIcon>>((ref) {
  final state = ref.watch(canvasProvider);
  if (state.mode == models.GenerationMode.image) return state.icons;
  return state.getVisibleIconsAt(state.currentTime).map((icon) => icon.interpolateAt(state.currentTime)).toList();
});

final visibleSketchesProvider = Provider<List<models.SketchStroke>>((ref) {
  final state = ref.watch(canvasProvider);
  return state.getVisibleSketchesAt(state.currentTime);
});

final visibleUserImagesProvider = Provider<List<models.UserImage>>((ref) {
  final state = ref.watch(canvasProvider);
  if (state.mode == models.GenerationMode.image) return state.userImages;
  return state.userImages.where((img) => state.currentTime >= img.startTime && state.currentTime <= img.endTime).toList();
});

final visibleUserVideosProvider = Provider<List<models.UserVideo>>((ref) {
  final state = ref.watch(canvasProvider);
  if (state.mode == models.GenerationMode.image) return [];
  return state.userVideos.where((v) => v.isVisibleAt(state.currentTime)).toList();
});
