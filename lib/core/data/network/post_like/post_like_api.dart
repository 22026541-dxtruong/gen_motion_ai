import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/dto/cursor_pagination.dto.dart';
import 'package:gen_motion_ai/core/data/network/dto/id_response.dto.dart';
import 'package:gen_motion_ai/core/data/network/post_like/dto/post_like_user.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'post_like_api.g.dart';

@RestApi()
abstract class PostLikeApi {
  factory PostLikeApi(Dio dio) = _PostLikeApi;

  @POST(ApiEndpoints.postLike)
  Future<IdResponseDto> likePost(@Path('postId') String postId);

  @GET(ApiEndpoints.postLike)
  Future<CursorPaginationDto<PostLikeUserDto>> getUsersLiked(
    @Path('postId') String postId,
    @Query('cursor') String? cursor,
    @Query('take') int take,
  );

  @DELETE(ApiEndpoints.postLike)
  Future<IdResponseDto> unlikePost(@Path('postId') String postId);
}
