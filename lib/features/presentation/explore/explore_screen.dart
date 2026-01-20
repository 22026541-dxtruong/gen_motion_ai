import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'All';
  
  final categories = [
    'All',
    'Trending',
    'Art',
    'Photography',
    'Character',
    'Landscape',
    'Architecture',
    'Abstract',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Categories filter
        _buildCategoryFilter(),
        
        // Grid content
        Expanded(
          child: _buildGrid(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: context.isMobile ? 56 : 60,
      padding: EdgeInsets.symmetric(horizontal: context.isMobile ? 16 : 24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: context.isMobile 
        ? _buildMobileCategories()
        : _buildDesktopCategories(),
    );
  }

  Widget _buildMobileCategories() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory == category;
        
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedCategory = category);
          },
          selectedColor: AppTheme.primaryColor,
          backgroundColor: AppTheme.cardColor,
          labelStyle: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        );
      },
    );
  }

  Widget _buildDesktopCategories() {
    return Row(
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategory = category);
                },
                selectedColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.cardColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.isMobile 
          ? 2 
          : (context.isTablet ? 3 : 4);
        
        return GridView.builder(
          padding: EdgeInsets.all(context.isMobile ? 16 : 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: context.isMobile ? 12 : 16,
            crossAxisSpacing: context.isMobile ? 12 : 16,
            childAspectRatio: 0.7,
          ),
          itemCount: 20,
          itemBuilder: (context, index) {
            return _ExploreCard(
              index: index,
              isMobile: context.isMobile,
            );
          },
        );
      },
    );
  }
}

class _ExploreCard extends StatefulWidget {
  final int index;
  final bool isMobile;
  
  const _ExploreCard({
    required this.index,
    required this.isMobile,
  });

  @override
  State<_ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<_ExploreCard> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        child: InkWell(
          onTap: () => context.push('/detail/${widget.index}'),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: widget.isMobile ? 36 : 48,
                          color: AppTheme.textSecondary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    
                    // Like button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          widget.index % 3 == 0 
                            ? Icons.favorite 
                            : Icons.favorite_border,
                          color: widget.index % 3 == 0 
                            ? Colors.red 
                            : Colors.white,
                          size: widget.isMobile ? 18 : 20,
                        ),
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          padding: EdgeInsets.all(widget.isMobile ? 6 : 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: EdgeInsets.all(widget.isMobile ? 8 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A beautiful ${["landscape", "portrait", "cityscape", "artwork"][widget.index % 4]}...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: widget.isMobile ? 12 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: widget.isMobile ? 6 : 8),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: widget.isMobile ? 12 : 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(widget.index + 1) * 123}',
                          style: TextStyle(
                            fontSize: widget.isMobile ? 11 : 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.remove_red_eye,
                          size: widget.isMobile ? 12 : 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(widget.index + 1) * 1234}',
                          style: TextStyle(
                            fontSize: widget.isMobile ? 11 : 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
