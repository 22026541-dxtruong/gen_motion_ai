import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/dto/cursor_pagination.dto.dart';
import 'package:gen_motion_ai/core/data/network/dto/id_response.dto.dart';
import 'package:gen_motion_ai/core/data/network/follow/dto/follower.dto.dart';
import 'package:gen_motion_ai/core/data/network/follow/dto/following.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'follow_api.g.dart';

@RestApi()
abstract class FollowApi {
  factory FollowApi(Dio dio, {String baseUrl}) = _FollowApi;

  @POST('/users/{userId}/follows')
  Future<IdResponseDto> follow(
    @Path('userId') String userId,
  );

  @DELETE('/users/{userId}/follows')
  Future<IdResponseDto> unfollow(
    @Path('userId') String userId,
  );

  @GET('/users/{userId}/followers')
  Future<CursorPaginationDto<FollowerDto>> getFollowers(
    @Path('userId') String userId,
    @Query('cursor') String? cursor,
    @Query('take') int take,
  );

  @GET('/users/{userId}/following')
  Future<CursorPaginationDto<FollowingDto>> getFollowings(
    @Path('userId') String userId,
    @Query('cursor') String? cursor,
    @Query('take') int take,
  );
}