import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/gallery/dto/gallery_item.dto.dart';

final galleryProvider =
    AsyncNotifierProvider<GalleryNotifier, List<GalleryItemDto>>(
  GalleryNotifier.new,
);

class GalleryNotifier extends AsyncNotifier<List<GalleryItemDto>> {
  @override
  Future<List<GalleryItemDto>> build() async {
    final api = ref.watch(galleryApiProvider);
    try {
      return await api.getGallery();
    } catch (_) {
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> removeItem(String id) async {
    final api = ref.read(galleryApiProvider);
    try {
      await api.removeFromGallery(id);
      await refresh();
    } catch (_) {}
  }
}
