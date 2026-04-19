import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/dto/cursor_pagination.dto.dart';
import 'package:gen_motion_ai/core/data/network/follow/dto/create_follow.dto.dart';
import 'package:gen_motion_ai/core/data/network/follow/dto/follower.dto.dart';
import 'package:gen_motion_ai/core/data/network/follow/dto/follow_record.dto.dart';
import 'package:gen_motion_ai/core/data/network/follow/dto/following.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'follow_api.g.dart';

@RestApi()
abstract class FollowApi {
  factory FollowApi(Dio dio, {String baseUrl}) = _FollowApi;

  @POST(ApiEndpoints.follows)
  Future<FollowRecordDto> follow(@Body() CreateFollowDto dto);

  @DELETE(ApiEndpoints.followByUserId)
  Future<FollowRecordDto> unfollow(@Path('userId') String userId);

  @GET(ApiEndpoints.userFollowers)
  Future<CursorPaginationDto<FollowerDto>> getFollowers(
    @Path('userId') String userId,
    @Query('cursor') String? cursor,
    @Query('take') int take,
  );

  @GET(ApiEndpoints.userFollowings)
  Future<CursorPaginationDto<FollowingDto>> getFollowings(
    @Path('userId') String userId,
    @Query('cursor') String? cursor,
    @Query('take') int take,
  );
}
