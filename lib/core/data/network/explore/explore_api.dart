import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/explore/dto/explore_item.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'explore_api.g.dart';

@RestApi()
abstract class ExploreApi {
  factory ExploreApi(Dio dio) = _ExploreApi;

  @GET(ApiEndpoints.explore)
  Future<List<ExploreItem>> getExplore({
    @Query("topic") String? topic,
    @Query("trending") String? trending,
    @Query("sort") String? sort,
    @Query("limit") int? limit,
    @Query("cursor") String? cursor,
  });
}