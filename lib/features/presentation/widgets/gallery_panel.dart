import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/features/presentation/canvas/canvas_provider.dart';

class GalleryPanel extends ConsumerStatefulWidget {
  const GalleryPanel({super.key});

  @override
  ConsumerState<GalleryPanel> createState() => _GalleryPanelState();
}

class _GalleryPanelState extends ConsumerState<GalleryPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for demonstration - in a real app this would come from an API/Provider
  final List<String> _mockImages = [
    'https://picsum.photos/id/10/400/400',
    'https://picsum.photos/id/11/400/400',
    'https://picsum.photos/id/12/400/400',
    'https://picsum.photos/id/13/400/400',
    'https://picsum.photos/id/14/400/400',
    'https://picsum.photos/id/15/400/400',
    'https://picsum.photos/id/16/400/400',
    'https://picsum.photos/id/17/400/400',
  ];

  final List<String> _mockVideos = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Images'),
            Tab(text: 'Videos'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGrid(_mockImages, isVideo: false),
              _buildGrid(_mockVideos, isVideo: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(List<String> urls, {required bool isVideo}) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: urls.length,
      itemBuilder: (context, index) {
        final url = urls[index];
        return GestureDetector(
          onTap: () {
            if (isVideo) {
              ref.read(canvasProvider.notifier).addUserVideo(url);
            } else {
              ref.read(canvasProvider.notifier).addUserImages([url]);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                isVideo
                    ? Container(color: Colors.black12)
                    : Image.network(url, fit: BoxFit.cover),
                if (isVideo)
                  const Center(child: Icon(Icons.play_circle_outline, size: 32, color: AppTheme.textPrimary)),
              ],
            ),
          ),
        );
      },
    );
  }
}