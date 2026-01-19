import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/features/presentation/canvas/canvas_provider.dart';
import 'package:gen_motion_ai/features/presentation/canvas/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIcon = ref.watch(selectedIconProvider);
    final selectedSketch = ref.watch(selectedSketchProvider);
    final canvasState = ref.watch(canvasProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          left: context.isDesktop 
            ? const BorderSide(color: AppTheme.borderColor)
            : BorderSide.none,
        ),
      ),
      child: selectedIcon != null
        ? _buildIconProperties(context, ref, selectedIcon, canvasState)
        : selectedSketch != null
        ? _buildSketchProperties(context, ref, selectedSketch, canvasState)
        : _buildEmptyState(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.isMobile ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: context.isMobile ? 40 : 64,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            SizedBox(height: context.isMobile ? 8 : 16),
            Text(
              'No selection',
              style: TextStyle(
                fontSize: context.isMobile ? 13 : 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: context.isMobile ? 4 : 8),
            Text(
              'Select an icon or sketch',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.isMobile ? 11 : 13,
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconProperties(BuildContext context, WidgetRef ref, CanvasIcon icon, CanvasState canvasState) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: icon.type.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon.type.icon,
                  color: icon.type.color,
                  size: context.isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: context.isMobile ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      icon.type.name,
                      style: TextStyle(
                        fontSize: context.isMobile ? 14 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      icon.type.category.label,
                      style: TextStyle(
                        fontSize: context.isMobile ? 11 : 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: context.isMobile ? 16 : 24),
          
          // Variations
          Text(
            'Style Variation',
            style: TextStyle(
              fontSize: context.isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.isMobile ? 8 : 12),
          
          Wrap(
            spacing: context.isMobile ? 6 : 8,
            runSpacing: context.isMobile ? 6 : 8,
            children: icon.type.variations.map<Widget>((variation) {
              final isSelected = icon.selectedVariation == variation;
              
              return InkWell(
                onTap: () {
                  ref.read(canvasProvider.notifier).selectVariation(icon.id, variation);
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isMobile ? 8 : 12,
                    vertical: context.isMobile ? 6 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                    ),
                  ),
                  child: Text(
                    variation,
                    style: TextStyle(
                      fontSize: context.isMobile ? 11 : 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: context.isMobile ? 16 : 24),
          
          _buildSliderControl(
            context,
            ref,
            'Size',
            icon.size,
            40,
            200,
            16,
            (value) => ref.read(canvasProvider.notifier).updateIconSize(icon.id, value),
          ),
          
          SizedBox(height: context.isMobile ? 16 : 24),
          
          _buildSliderControl(
            context,
            ref,
            'Rotation',
            icon.rotation,
            0,
            360,
            36,
            (value) => ref.read(canvasProvider.notifier).updateIconRotation(icon.id, value),
            suffix: '°',
          ),
          
          if (canvasState.mode == GenerationMode.video) ...[
            SizedBox(height: context.isMobile ? 16 : 24),
            Divider(color: AppTheme.borderColor),
            SizedBox(height: context.isMobile ? 16 : 24),
            
            Text(
              'Video Timeline',
              style: TextStyle(
                fontSize: context.isMobile ? 13 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.isMobile ? 12 : 16),
            
            _buildTimeControl(
              context,
              ref,
              'Start Time',
              icon.startTime,
              0,
              canvasState.videoDuration,
              (value) => ref.read(canvasProvider.notifier).updateIconTimeline(
                icon.id,
                startTime: value,
              ),
            ),
            
            SizedBox(height: context.isMobile ? 12 : 16),
            
            _buildTimeControl(
              context,
              ref,
              'End Time',
              icon.endTime,
              icon.startTime + 0.5,
              canvasState.videoDuration,
              (value) => ref.read(canvasProvider.notifier).updateIconTimeline(
                icon.id,
                endTime: value,
              ),
            ),
            
            SizedBox(height: context.isMobile ? 12 : 16),
            
            _buildInfoCard(
              'Duration',
              '${(icon.endTime - icon.startTime).toStringAsFixed(1)}s',
              Icons.timer_outlined,
              context,
            ),
            
            SizedBox(height: context.isMobile ? 12 : 16),
            
            Text(
              'Animation',
              style: TextStyle(
                fontSize: context.isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.isMobile ? 8 : 12),
            
            DropdownButtonFormField<String>(
              value: icon.animation,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.isMobile ? 10 : 14,
                  vertical: context.isMobile ? 8 : 12,
                ),
              ),
              items: AnimationType.all.map((anim) {
                return DropdownMenuItem(
                  value: anim,
                  child: Text(
                    _formatAnimationName(anim),
                    style: TextStyle(fontSize: context.isMobile ? 12 : 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(canvasProvider.notifier).updateIconAnimation(icon.id, value);
                }
              },
            ),
          ],
          
          SizedBox(height: context.isMobile ? 16 : 24),
          
          _buildInfoCard(
            'Position',
            'X: ${icon.position.dx.round()}, Y: ${icon.position.dy.round()}',
            Icons.place_outlined,
            context,
          ),
          
          SizedBox(height: context.isMobile ? 16 : 24),
          
          OutlinedButton.icon(
            onPressed: () {
              ref.read(canvasProvider.notifier).deleteIcon(icon.id);
            },
            icon: Icon(Icons.delete_outline, size: context.isMobile ? 16 : 18),
            label: Text(
              'Remove',
              style: TextStyle(fontSize: context.isMobile ? 12 : 14),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(
                vertical: context.isMobile ? 8 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSketchProperties(BuildContext context, WidgetRef ref, SketchStroke sketch, CanvasState canvasState) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.draw,
                  color: AppTheme.primaryColor,
                  size: context.isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: context.isMobile ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sketch Stroke',
                      style: TextStyle(
                        fontSize: context.isMobile ? 14 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${sketch.points.length} points',
                      style: TextStyle(
                        fontSize: context.isMobile ? 11 : 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: context.isMobile ? 16 : 24),
          
          // Color Picker
          Text(
            'Color',
            style: TextStyle(
              fontSize: context.isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.isMobile ? 8 : 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Colors.black, Colors.white, Colors.grey, Colors.red, Colors.pink,
              Colors.purple, Colors.deepPurple, Colors.indigo, Colors.blue, Colors.lightBlue,
              Colors.cyan, Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
              Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange, Colors.brown,
            ].map((color) {
              final isSelected = sketch.color.value == color.value;
              return GestureDetector(
                onTap: () => ref.read(canvasProvider.notifier).updateSketchColor(sketch.id, color),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: context.isMobile ? 16 : 24),

          // Stroke Width
          _buildSliderControl(
            context,
            ref,
            'Stroke Width',
            sketch.strokeWidth,
            1,
            50,
            49,
            (value) => ref.read(canvasProvider.notifier).updateSketchStrokeWidth(sketch.id, value),
            suffix: 'px',
          ),
          
          SizedBox(height: context.isMobile ? 12 : 16),
          
          _buildSliderControl(
            context,
            ref,
            'Scale',
            sketch.scale,
            0.1,
            3.0,
            29,
            (value) => ref.read(canvasProvider.notifier).updateSketchScale(sketch.id, value),
            suffix: 'x',
          ),
          
          SizedBox(height: context.isMobile ? 12 : 16),
          
          _buildSliderControl(
            context,
            ref,
            'Rotation',
            sketch.rotation,
            0,
            360,
            36,
            (value) => ref.read(canvasProvider.notifier).updateSketchRotation(sketch.id, value),
            suffix: '°',
          ),
          
          SizedBox(height: context.isMobile ? 12 : 16),
          
          _buildSliderControl(
            context,
            ref,
            'Position X',
            sketch.position.dx,
            -500,
            1500,
            2000,
            (value) => ref.read(canvasProvider.notifier).updateSketchPosition(
              sketch.id, 
              Offset(value, sketch.position.dy)
            ),
          ),
          
          SizedBox(height: context.isMobile ? 12 : 16),
          
          _buildSliderControl(
            context,
            ref,
            'Position Y',
            sketch.position.dy,
            -500,
            1500,
            2000,
            (value) => ref.read(canvasProvider.notifier).updateSketchPosition(
              sketch.id, 
              Offset(sketch.position.dx, value)
            ),
          ),
          
          if (canvasState.mode == GenerationMode.video) ...[
            SizedBox(height: context.isMobile ? 16 : 24),
            Divider(color: AppTheme.borderColor),
            SizedBox(height: context.isMobile ? 16 : 24),
            
            Text(
              'Video Timeline',
              style: TextStyle(
                fontSize: context.isMobile ? 13 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.isMobile ? 12 : 16),
            
            _buildTimeControl(
              context,
              ref,
              'Start Time',
              sketch.startTime,
              0,
              canvasState.videoDuration,
              (value) => ref.read(canvasProvider.notifier).updateSketchTimeline(
                sketch.id,
                startTime: value,
              ),
            ),
            
            SizedBox(height: context.isMobile ? 12 : 16),
            
            _buildTimeControl(
              context,
              ref,
              'End Time',
              sketch.endTime == double.infinity ? canvasState.videoDuration : sketch.endTime,
              sketch.startTime + 0.5,
              canvasState.videoDuration,
              (value) => ref.read(canvasProvider.notifier).updateSketchTimeline(
                sketch.id,
                endTime: value,
              ),
            ),
            
            SizedBox(height: context.isMobile ? 12 : 16),
            
            _buildInfoCard(
              'Duration',
              sketch.endTime == double.infinity
                ? '${(canvasState.videoDuration - sketch.startTime).toStringAsFixed(1)}s (End)'
                : '${(sketch.endTime - sketch.startTime).toStringAsFixed(1)}s',
              Icons.timer_outlined,
              context,
            ),
          ],
          
          SizedBox(height: context.isMobile ? 16 : 24),
          
          OutlinedButton.icon(
            onPressed: () {
              ref.read(canvasProvider.notifier).deleteSketch(sketch.id);
            },
            icon: Icon(Icons.delete_outline, size: context.isMobile ? 16 : 18),
            label: Text(
              'Remove Sketch',
              style: TextStyle(fontSize: context.isMobile ? 12 : 14),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(
                vertical: context.isMobile ? 8 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl(
    BuildContext context,
    WidgetRef ref,
    String label,
    double value,
    double min,
    double max,
    int divisions,
    Function(double) onChanged, {
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.isMobile ? 12 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.isMobile ? 8 : 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                label: '${value.round()}$suffix',
                activeColor: AppTheme.primaryColor,
                onChanged: onChanged,
              ),
            ),
            SizedBox(width: context.isMobile ? 8 : 12),
            Container(
              width: context.isMobile ? 45 : 60,
              padding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? 6 : 8,
                vertical: context.isMobile ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text(
                '${value.round()}$suffix',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.isMobile ? 11 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeControl(
    BuildContext context,
    WidgetRef ref,
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: context.isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}s',
              style: TextStyle(
                fontSize: context.isMobile ? 11 : 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: context.isMobile ? 6 : 8),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) * 10).toInt(),
          activeColor: AppTheme.primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: context.isMobile ? 14 : 18, color: AppTheme.textSecondary),
          SizedBox(width: context.isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: context.isMobile ? 10 : 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: context.isMobile ? 1 : 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.isMobile ? 11 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAnimationName(String animation) {
    return animation.split('-').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
