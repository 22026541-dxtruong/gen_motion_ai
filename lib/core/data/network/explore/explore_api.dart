import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/explore/dto/batch_record_explore_events.dto.dart';
import 'package:gen_motion_ai/core/data/network/explore/dto/batch_record_explore_events_response.dto.dart';
import 'package:gen_motion_ai/core/data/network/explore/dto/explore_feed.dto.dart';
import 'package:gen_motion_ai/core/data/network/explore/dto/record_explore_event.dto.dart';
import 'package:gen_motion_ai/core/data/network/explore/dto/record_explore_event_response.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'explore_api.g.dart';

@RestApi()
abstract class ExploreApi {
  factory ExploreApi(Dio dio) = _ExploreApi;

  @GET(ApiEndpoints.explore)
  Future<ExploreFeedDto> getExplore({
    @Query("mode") String? mode,
    @Query("topic") String? topic,
    @Query("trending") String? trending,
    @Query("sort") String? sort,
    @Query("limit") int? limit,
    @Query("cursor") String? cursor,
  });

  @GET(ApiEndpoints.exploreForYou)
  Future<ExploreFeedDto> getForYou({
    @Query("mode") String? mode,
    @Query("topic") String? topic,
    @Query("trending") String? trending,
    @Query("sort") String? sort,
    @Query("limit") int? limit,
    @Query("cursor") String? cursor,
  });

  @POST(ApiEndpoints.exploreEvents)
  Future<RecordExploreEventResponseDto> recordEvent(
    @Body() RecordExploreEventDto dto,
  );

  @POST(ApiEndpoints.exploreEventsBatch)
  Future<BatchRecordExploreEventsResponseDto> recordEventsBatch(
    @Body() BatchRecordExploreEventsDto dto,
  );
}
