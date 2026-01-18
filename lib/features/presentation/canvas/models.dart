import 'package:flutter/material.dart';

// Generation mode
enum GenerationMode {
  image('Image', Icons.image),
  video('Video', Icons.videocam);

  final String label;
  final IconData icon;
  const GenerationMode(this.label, this.icon);
}

// Smart Icon categories
enum IconCategory {
  nature('Nature', Icons.nature),
  building('Building', Icons.home),
  character('Character', Icons.person),
  celestial('Celestial', Icons.wb_sunny),
  animal('Animal', Icons.pets),
  object('Object', Icons.widgets);

  final String label;
  final IconData icon;
  const IconCategory(this.label, this.icon);
}

// Smart Icon Type
class SmartIconType {
  final String id;
  final String name;
  final IconCategory category;
  final IconData icon;
  final List<String> variations;
  final Color color;

  const SmartIconType({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.variations,
    required this.color,
  });
}

// Predefined smart icons library
class SmartIconLibrary {
  static final List<SmartIconType> icons = [
    // Nature
    SmartIconType(
      id: 'tree',
      name: 'Tree',
      category: IconCategory.nature,
      icon: Icons.park,
      variations: [
        'Oak Tree',
        'Pine Tree',
        'Autumn Tree',
        'Dead Tree',
        'Palm Tree',
      ],
      color: Colors.green,
    ),
    SmartIconType(
      id: 'mountain',
      name: 'Mountain',
      category: IconCategory.nature,
      icon: Icons.terrain,
      variations: ['Snow Peak', 'Rocky Mountain', 'Hill', 'Volcano'],
      color: Colors.brown,
    ),
    SmartIconType(
      id: 'flower',
      name: 'Flower',
      category: IconCategory.nature,
      icon: Icons.local_florist,
      variations: ['Rose', 'Sunflower', 'Tulip', 'Wildflower'],
      color: Colors.pink,
    ),
    SmartIconType(
      id: 'water',
      name: 'Water',
      category: IconCategory.nature,
      icon: Icons.water,
      variations: ['River', 'Lake', 'Ocean', 'Waterfall', 'Rain'],
      color: Colors.blue,
    ),
    SmartIconType(
      id: 'cloud',
      name: 'Cloud',
      category: IconCategory.celestial,
      icon: Icons.cloud,
      variations: ['White Cloud', 'Storm Cloud', 'Wispy Cloud', 'Fog'],
      color: Colors.blueGrey,
    ),

    // Buildings
    SmartIconType(
      id: 'house',
      name: 'House',
      category: IconCategory.building,
      icon: Icons.home,
      variations: ['Modern House', 'Cottage', 'Mansion', 'Cabin', 'Villa'],
      color: Colors.orange,
    ),
    SmartIconType(
      id: 'building',
      name: 'Building',
      category: IconCategory.building,
      icon: Icons.apartment,
      variations: ['Skyscraper', 'Office Building', 'Tower', 'Castle'],
      color: Colors.grey,
    ),
    SmartIconType(
      id: 'bridge',
      name: 'Bridge',
      category: IconCategory.building,
      icon: Icons.badge,
      variations: ['Suspension Bridge', 'Arch Bridge', 'Wooden Bridge'],
      color: Colors.brown,
    ),

    // Characters
    SmartIconType(
      id: 'person',
      name: 'Person',
      category: IconCategory.character,
      icon: Icons.person,
      variations: ['Male', 'Female', 'Child', 'Elder', 'Athlete'],
      color: Colors.purple,
    ),
    SmartIconType(
      id: 'group',
      name: 'Group',
      category: IconCategory.character,
      icon: Icons.group,
      variations: ['Couple', 'Family', 'Friends', 'Crowd'],
      color: Colors.deepPurple,
    ),

    // Celestial
    SmartIconType(
      id: 'sun',
      name: 'Sun',
      category: IconCategory.celestial,
      icon: Icons.wb_sunny,
      variations: ['Sunrise', 'Noon Sun', 'Sunset', 'Eclipse'],
      color: Colors.yellow,
    ),
    SmartIconType(
      id: 'moon',
      name: 'Moon',
      category: IconCategory.celestial,
      icon: Icons.nightlight,
      variations: ['Full Moon', 'Crescent Moon', 'Half Moon'],
      color: Colors.grey.shade400,
    ),

    // Animals
    SmartIconType(
      id: 'bird',
      name: 'Bird',
      category: IconCategory.animal,
      icon: Icons.flutter_dash,
      variations: ['Eagle', 'Dove', 'Crow', 'Parrot', 'Swan'],
      color: Colors.teal,
    ),
    SmartIconType(
      id: 'dog',
      name: 'Dog',
      category: IconCategory.animal,
      icon: Icons.pets,
      variations: ['Puppy', 'Adult Dog', 'Wolf', 'Husky'],
      color: Colors.brown,
    ),
    SmartIconType(
      id: 'cat',
      name: 'Cat',
      category: IconCategory.animal,
      icon: Icons.pets,
      variations: ['Kitten', 'Adult Cat', 'Tiger', 'Lion'],
      color: Colors.orange.shade800,
    ),

    // Objects
    SmartIconType(
      id: 'car',
      name: 'Car',
      category: IconCategory.object,
      icon: Icons.directions_car,
      variations: ['Sports Car', 'SUV', 'Vintage Car', 'Electric Car'],
      color: Colors.red,
    ),
    SmartIconType(
      id: 'boat',
      name: 'Boat',
      category: IconCategory.object,
      icon: Icons.directions_boat,
      variations: ['Sailboat', 'Yacht', 'Fishing Boat', 'Speedboat'],
      color: Colors.blue,
    ),
  ];

  static List<SmartIconType> getByCategory(IconCategory category) {
    return icons.where((icon) => icon.category == category).toList();
  }
}

// Keyframe for animation
class Keyframe {
  final double time; // seconds
  final Offset position;
  final double size;
  final double rotation;
  final double opacity;

  Keyframe({
    required this.time,
    required this.position,
    required this.size,
    required this.rotation,
    this.opacity = 1.0,
  });

  Keyframe copyWith({
    double? time,
    Offset? position,
    double? size,
    double? rotation,
    double? opacity,
  }) {
    return Keyframe(
      time: time ?? this.time,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
    );
  }
}

// Canvas Icon Instance with keyframes
class CanvasIcon {
  final String id;
  final SmartIconType type;
  final Offset position;
  final double size;
  final double rotation;
  final String? selectedVariation;
  final double opacity;

  // Video timeline properties
  final double startTime;
  final double endTime;
  final String animation;
  final double animationDuration;

  // Keyframe animation
  final List<Keyframe> keyframes;

  CanvasIcon({
    required this.id,
    required this.type,
    required this.position,
    this.size = 80,
    this.rotation = 0,
    this.selectedVariation,
    this.opacity = 1.0,
    this.startTime = 0,
    this.endTime = 5,
    this.animation = 'fade-in',
    this.animationDuration = 0.5,
    this.keyframes = const [],
  });

  CanvasIcon copyWith({
    Offset? position,
    double? size,
    double? rotation,
    String? selectedVariation,
    double? opacity,
    double? startTime,
    double? endTime,
    String? animation,
    double? animationDuration,
    List<Keyframe>? keyframes,
  }) {
    return CanvasIcon(
      id: id,
      type: type,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      selectedVariation: selectedVariation ?? this.selectedVariation,
      opacity: opacity ?? this.opacity,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      animation: animation ?? this.animation,
      animationDuration: animationDuration ?? this.animationDuration,
      keyframes: keyframes ?? this.keyframes,
    );
  }

  bool isVisibleAt(double time) {
    return time >= startTime && time <= endTime;
  }

  // Interpolate properties at specific time using keyframes
  CanvasIcon interpolateAt(double time) {
    if (keyframes.isEmpty) return this;

    // Find surrounding keyframes
    Keyframe? before;
    Keyframe? after;

    for (final kf in keyframes) {
      if (kf.time <= time) {
        if (before == null || kf.time > before.time) {
          before = kf;
        }
      }
      if (kf.time >= time) {
        if (after == null || kf.time < after.time) {
          after = kf;
        }
      }
    }

    if (before == null && after == null) return this;
    if (before == null) {
      return copyWith(
        position: after!.position,
        size: after.size,
        rotation: after.rotation,
        opacity: after.opacity,
      );
    }
    if (after == null) {
      return copyWith(
        position: before.position,
        size: before.size,
        rotation: before.rotation,
        opacity: before.opacity,
      );
    }
    if (before.time == after.time) {
      return copyWith(
        position: before.position,
        size: before.size,
        rotation: before.rotation,
        opacity: before.opacity,
      );
    }

    // Linear interpolation
    final t = (time - before.time) / (after.time - before.time);

    return copyWith(
      position: Offset.lerp(before.position, after.position, t),
      size: before.size + (after.size - before.size) * t,
      rotation: before.rotation + (after.rotation - before.rotation) * t,
      opacity: before.opacity + (after.opacity - before.opacity) * t,
    );
  }
}

// Sketch stroke (persistent drawing)
class SketchStroke {
  final String id;
  final List<DrawingPoint> points;
  final double startTime;
  final double endTime;
  final Color color;
  final double strokeWidth;

  SketchStroke({
    required this.id,
    required this.points,
    this.startTime = 0,
    this.endTime = double.infinity,
    this.color = Colors.black,
    this.strokeWidth = 3,
  });

  SketchStroke copyWith({
    List<DrawingPoint>? points,
    double? startTime,
    double? endTime,
    Color? color,
    double? strokeWidth,
  }) {
    return SketchStroke(
      id: id,
      points: points ?? this.points,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  bool isVisibleAt(double time) {
    return time >= startTime && time <= endTime;
  }
}

// Canvas State
class CanvasState {
  final List<CanvasIcon> icons;
  final List<SketchStroke> sketches; // Persistent sketch strokes
  final Color backgroundColor;
  final String? selectedIconId;
  final String? selectedSketchId;
  final List<DrawingPoint> currentSketchPoints; // Current drawing
  final bool isDrawingMode;
  final GenerationMode mode;

  // Video timeline properties
  final double videoDuration;
  final double currentTime;
  final bool isPlaying;
  final bool showTimeline;

  // Canvas view properties
  final double zoom;
  final Offset pan;

  CanvasState({
    this.icons = const [],
    this.sketches = const [],
    this.backgroundColor = Colors.white,
    this.selectedIconId,
    this.selectedSketchId,
    this.currentSketchPoints = const [],
    this.isDrawingMode = false,
    this.mode = GenerationMode.image,
    this.videoDuration = 10.0,
    this.currentTime = 0.0,
    this.isPlaying = false,
    this.showTimeline = true,
    this.zoom = 1.0,
    this.pan = Offset.zero,
  });

  CanvasState copyWith({
    List<CanvasIcon>? icons,
    List<SketchStroke>? sketches,
    Color? backgroundColor,
    String? selectedIconId,
    String? selectedSketchId,
    List<DrawingPoint>? currentSketchPoints,
    bool? isDrawingMode,
    GenerationMode? mode,
    double? videoDuration,
    double? currentTime,
    bool? isPlaying,
    bool? showTimeline,
    double? zoom,
    Offset? pan,
  }) {
    return CanvasState(
      icons: icons ?? this.icons,
      sketches: sketches ?? this.sketches,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedIconId: selectedIconId,
      selectedSketchId: selectedSketchId,
      currentSketchPoints: currentSketchPoints ?? this.currentSketchPoints,
      isDrawingMode: isDrawingMode ?? this.isDrawingMode,
      mode: mode ?? this.mode,
      videoDuration: videoDuration ?? this.videoDuration,
      currentTime: currentTime ?? this.currentTime,
      isPlaying: isPlaying ?? this.isPlaying,
      showTimeline: showTimeline ?? this.showTimeline,
      zoom: zoom ?? this.zoom,
      pan: pan ?? this.pan,
    );
  }

  List<CanvasIcon> getVisibleIconsAt(double time) {
    if (mode == GenerationMode.image) {
      return icons;
    }
    return icons.where((icon) => icon.isVisibleAt(time)).toList();
  }

  List<SketchStroke> getVisibleSketchesAt(double time) {
    if (mode == GenerationMode.image) {
      return sketches;
    }
    return sketches.where((sketch) => sketch.isVisibleAt(time)).toList();
  }
}

// Drawing point for sketch mode
class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final double timestamp;

  DrawingPoint({
    required this.offset,
    required this.paint,
    this.timestamp = 0.0,
  });
}

// Animation types
class AnimationType {
  static const String none = 'none';
  static const String fadeIn = 'fade-in';
  static const String fadeOut = 'fade-out';
  static const String slideLeft = 'slide-left';
  static const String slideRight = 'slide-right';
  static const String slideUp = 'slide-up';
  static const String slideDown = 'slide-down';
  static const String zoomIn = 'zoom-in';
  static const String zoomOut = 'zoom-out';
  static const String rotate = 'rotate';

  static List<String> get all => [
    none,
    fadeIn,
    fadeOut,
    slideLeft,
    slideRight,
    slideUp,
    slideDown,
    zoomIn,
    zoomOut,
    rotate,
  ];
}
