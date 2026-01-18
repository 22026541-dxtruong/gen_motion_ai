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
        ? _buildProperties(context, ref, selectedIcon, canvasState)
        : _buildEmptyState(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: context.isMobile ? 48 : 64,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            SizedBox(height: context.isMobile ? 12 : 16),
            Text(
              'No icon selected',
              style: TextStyle(
                fontSize: context.isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: context.isMobile ? 6 : 8),
            Text(
              'Select an icon to edit properties',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.isMobile ? 12 : 13,
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProperties(BuildContext context, WidgetRef ref, CanvasIcon icon, CanvasState canvasState) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: icon.type.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon.type.icon, color: icon.type.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      icon.type.name,
                      style: TextStyle(
                        fontSize: context.isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      icon.type.category.label,
                      style: TextStyle(
                        fontSize: context.isMobile ? 12 : 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: context.isMobile ? 20 : 24),
          
          // Variations
          Text(
            'Style Variation',
            style: TextStyle(
              fontSize: context.isMobile ? 13 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: icon.type.variations.map<Widget>((variation) {
              final isSelected = icon.selectedVariation == variation;
              
              return InkWell(
                onTap: () {
                  ref.read(canvasProvider.notifier).selectVariation(
                    icon.id,
                    variation,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isMobile ? 10 : 12,
                    vertical: context.isMobile ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.borderColor,
                    ),
                  ),
                  child: Text(
                    variation,
                    style: TextStyle(
                      fontSize: context.isMobile ? 12 : 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: context.isMobile ? 20 : 24),
          
          // Size
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
          
          SizedBox(height: context.isMobile ? 20 : 24),
          
          // Rotation
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
          
          // Video Timeline Properties
          if (canvasState.mode == GenerationMode.video) ...[
            SizedBox(height: context.isMobile ? 20 : 24),
            const Divider(color: AppTheme.borderColor),
            SizedBox(height: context.isMobile ? 20 : 24),
            
            Text(
              'Video Timeline',
              style: TextStyle(
                fontSize: context.isMobile ? 15 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Start Time
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
            
            const SizedBox(height: 16),
            
            // End Time
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
            
            const SizedBox(height: 16),
            
            // Duration display
            _buildInfoCard(
              'Duration',
              '${(icon.endTime - icon.startTime).toStringAsFixed(1)}s',
              Icons.timer_outlined,
              context,
            ),
            
            const SizedBox(height: 16),
            
            // Animation
            Text(
              'Animation',
              style: TextStyle(
                fontSize: context.isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            DropdownButtonFormField<String>(
              value: icon.animation,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.isMobile ? 12 : 14,
                  vertical: context.isMobile ? 10 : 12,
                ),
              ),
              items: AnimationType.all.map((anim) {
                return DropdownMenuItem(
                  value: anim,
                  child: Text(
                    _formatAnimationName(anim),
                    style: TextStyle(fontSize: context.isMobile ? 13 : 14),
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
          
          SizedBox(height: context.isMobile ? 20 : 24),
          
          // Position info
          _buildInfoCard(
            'Position',
            'X: ${icon.position.dx.round()}, Y: ${icon.position.dy.round()}',
            Icons.place_outlined,
            context,
          ),
          
          SizedBox(height: context.isMobile ? 20 : 24),
          
          // Actions
          OutlinedButton.icon(
            onPressed: () {
              ref.read(canvasProvider.notifier).deleteIcon(icon.id);
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Remove from Canvas'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(
                vertical: context.isMobile ? 10 : 12,
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
            fontSize: context.isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
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
            const SizedBox(width: 12),
            Container(
              width: context.isMobile ? 50 : 60,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text(
                '${value.round()}$suffix',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.isMobile ? 12 : 13,
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
                fontSize: context.isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}s',
              style: TextStyle(
                fontSize: context.isMobile ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
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
      padding: EdgeInsets.all(context.isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: context.isMobile ? 11 : 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.isMobile ? 12 : 13,
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
