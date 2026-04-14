import 'package:flutter/material.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:video_player/video_player.dart';

class NetworkVideoPlayer extends StatefulWidget {
  const NetworkVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.autoPlay = false,
  });

  final String videoUrl;
  final String? thumbnailUrl;
  final bool autoPlay;

  @override
  State<NetworkVideoPlayer> createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends State<NetworkVideoPlayer> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  @override
  void didUpdateWidget(covariant NetworkVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _setupController();
    }
  }

  void _setupController() {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _controller = controller;
    _initializeFuture = controller.initialize().then((_) {
      controller.setLooping(true);
      if (widget.autoPlay) {
        controller.play();
      }
      if (mounted) {
        setState(() {});
      }
    });
    controller.addListener(_onControllerTick);
  }

  void _onControllerTick() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _disposeController() {
    _controller?.removeListener(_onControllerTick);
    _controller?.dispose();
    _controller = null;
    _initializeFuture = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final controller = _controller;
    if (controller == null || _initializeFuture == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<void>(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildFallback(
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !controller.value.isInitialized) {
          return _buildFallback(
            child: Center(
              child: Icon(
                Icons.movie_creation_outlined,
                size: 36,
                color: colors.textSecondary,
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.55),
                ),
                onPressed: () {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallback({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.thumbnailUrl != null)
              Image.network(widget.thumbnailUrl!, fit: BoxFit.cover)
            else
              Builder(
                builder: (context) =>
                    Container(color: context.appColors.surface),
              ),
            DecoratedBox(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.25)),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
