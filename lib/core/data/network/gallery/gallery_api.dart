import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/gallery/dto/gallery_item.dto.dart';
import 'package:gen_motion_ai/core/data/network/gallery/dto/create_gallery.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'gallery_api.g.dart';

@RestApi()
abstract class GalleryApi {
  factory GalleryApi(Dio dio) = _GalleryApi;

  @GET(ApiEndpoints.gallery)
  Future<List<GalleryItemDto>> getGallery();

  @POST(ApiEndpoints.gallery)
  Future<dynamic> addToGallery(@Body() CreateGalleryDto body);

  @DELETE('/gallery/{id}')
  Future<dynamic> removeFromGallery(@Path('id') String id);
}
