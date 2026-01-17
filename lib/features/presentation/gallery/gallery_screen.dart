import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selectedFilter = 'All';
  bool _isGridView = true;
  
  final filters = ['All', 'Images', 'Videos', 'Favorites'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        _buildToolbar(),
        
        // Content
        Expanded(
          child: _isGridView ? _buildGridView() : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: context.isMobile ? 100 : 60,
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 16 : 24,
        vertical: context.isMobile ? 12 : 0,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: context.isMobile 
        ? _buildMobileToolbar()
        : _buildDesktopToolbar(),
    );
  }

  Widget _buildMobileToolbar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedFilter = filter);
                        },
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: AppTheme.cardColor,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() => _isGridView = !_isGridView);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sort, size: 18),
                label: const Text('Sort', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopToolbar() {
    return Row(
      children: [
        // Filters
        ...filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              selectedColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.cardColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          );
        }),
        
        const Spacer(),
        
        // Actions
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.sort),
          label: const Text('Sort'),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Selected'),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            setState(() => _isGridView = !_isGridView);
          },
        ),
      ],
    );
  }

  Widget _buildGridView() {
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
            childAspectRatio: 0.75,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            return _GalleryGridItem(
              index: index,
              isMobile: context.isMobile,
            );
          },
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: EdgeInsets.all(context.isMobile ? 16 : 24),
      itemCount: 16,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _GalleryListItem(
          index: index,
          isMobile: context.isMobile,
        );
      },
    );
  }
}

class _GalleryGridItem extends StatefulWidget {
  final int index;
  final bool isMobile;
  
  const _GalleryGridItem({
    required this.index,
    required this.isMobile,
  });

  @override
  State<_GalleryGridItem> createState() => _GalleryGridItemState();
}

class _GalleryGridItemState extends State<_GalleryGridItem> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
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
                ),
                Padding(
                  padding: EdgeInsets.all(widget.isMobile ? 8 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generation ${widget.index + 1}',
                        style: TextStyle(
                          fontSize: widget.isMobile ? 12 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: widget.isMobile ? 4 : 6),
                      Text(
                        '2 hours ago',
                        style: TextStyle(
                          fontSize: widget.isMobile ? 11 : 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Selection checkbox
            Positioned(
              top: 8,
              left: 8,
              child: Checkbox(
                value: _isSelected,
                onChanged: (value) {
                  setState(() => _isSelected = value ?? false);
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),
            
            // Actions menu
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.more_vert, size: 18),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'download',
                    child: Text('Download'),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Text('Share'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryListItem extends StatefulWidget {
  final int index;
  final bool isMobile;
  
  const _GalleryListItem({
    required this.index,
    required this.isMobile,
  });

  @override
  State<_GalleryListItem> createState() => _GalleryListItemState();
}

class _GalleryListItemState extends State<_GalleryListItem> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: _isSelected,
                onChanged: (value) {
                  setState(() => _isSelected = value ?? false);
                },
                activeColor: AppTheme.primaryColor,
              ),
              
              SizedBox(width: widget.isMobile ? 12 : 16),
              
              // Thumbnail
              Container(
                width: widget.isMobile ? 60 : 80,
                height: widget.isMobile ? 60 : 80,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: widget.isMobile ? 24 : 32,
                  color: AppTheme.textSecondary.withOpacity(0.3),
                ),
              ),
              
              SizedBox(width: widget.isMobile ? 12 : 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generation ${widget.index + 1}',
                      style: TextStyle(
                        fontSize: widget.isMobile ? 14 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: widget.isMobile ? 4 : 6),
                    Text(
                      'A beautiful landscape with mountains...',
                      maxLines: widget.isMobile ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: widget.isMobile ? 12 : 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: widget.isMobile ? 4 : 6),
                    Text(
                      '2 hours ago',
                      style: TextStyle(
                        fontSize: widget.isMobile ? 11 : 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              if (!widget.isMobile)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
              
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'download',
                    child: Text('Download'),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Text('Share'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
