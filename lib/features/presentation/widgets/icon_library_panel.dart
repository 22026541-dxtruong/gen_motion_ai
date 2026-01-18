import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/features/presentation/canvas/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class IconLibraryPanel extends ConsumerStatefulWidget {
  const IconLibraryPanel({super.key});

  @override
  ConsumerState<IconLibraryPanel> createState() => _IconLibraryPanelState();
}

class _IconLibraryPanelState extends ConsumerState<IconLibraryPanel> {
  IconCategory _selectedCategory = IconCategory.nature;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          right: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(context.isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.widgets, size: 20, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Smart Icons',
                      style: TextStyle(
                        fontSize: context.isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.isMobile ? 12 : 16),
                
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search icons...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: AppTheme.borderColor),
          
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: IconCategory.values.length,
              itemBuilder: (context, index) {
                final category = IconCategory.values[index];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon, size: 16),
                        const SizedBox(width: 6),
                        Text(category.label),
                      ],
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: AppTheme.cardColor,
                    labelStyle: TextStyle(
                      fontSize: context.isMobile ? 12 : 13,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 1, color: AppTheme.borderColor),
          
          Expanded(
            child: _buildIconGrid(),
          ),
          
          Container(
            padding: EdgeInsets.all(context.isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              border: const Border(
                top: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap & drag icons to canvas',
                    style: TextStyle(
                      fontSize: context.isMobile ? 11 : 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconGrid() {
    final icons = SmartIconLibrary.getByCategory(_selectedCategory).where((icon) {
      if (_searchQuery.isEmpty) return true;
      return icon.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (icons.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No icons found',
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(context.isMobile ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isMobile ? 3 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        return _IconLibraryItem(icon: icons[index]);
      },
    );
  }
}

class _IconLibraryItem extends StatefulWidget {
  final SmartIconType icon;

  const _IconLibraryItem({required this.icon});

  @override
  State<_IconLibraryItem> createState() => _IconLibraryItemState();
}

class _IconLibraryItemState extends State<_IconLibraryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Draggable<SmartIconType>(
        data: widget.icon,
        // INSTANT FEEDBACK - no long press needed!
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.icon.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.icon.color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.icon.icon,
              size: 40,
              color: widget.icon.color,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildCard(),
        ),
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.icon.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isHovered ? widget.icon.color : AppTheme.borderColor,
          width: _isHovered ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon.icon,
            size: context.isMobile ? 32 : 36,
            color: widget.icon.color,
          ),
          const SizedBox(height: 8),
          Text(
            widget.icon.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${widget.icon.variations.length} styles',
            style: TextStyle(
              fontSize: context.isMobile ? 9 : 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
