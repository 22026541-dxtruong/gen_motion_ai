import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/comment/dto/comment.dto.dart';
import 'package:gen_motion_ai/core/data/network/comment/dto/create_comment.dto.dart';
import 'package:gen_motion_ai/core/data/network/comment/dto/update_comment.dto.dart';
import 'package:gen_motion_ai/core/data/network/dto/cursor_pagination.dto.dart';
import 'package:gen_motion_ai/core/data/network/dto/id_response.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'comment_api.g.dart';

@RestApi()
abstract class CommentApi {
  factory CommentApi(Dio dio, {String baseUrl}) = _CommentApi;

  @POST(ApiEndpoints.postComments)
  Future<IdResponseDto> createComment(
    @Path('postId') String postId,
    @Body() CreateCommentDto dto,
  );

  @GET(ApiEndpoints.postComments)
  Future<CursorPaginationDto<CommentDto>> getComments(
    @Path('postId') String postId,
    @Query('cursor') String? cursor,
    @Query('take') int take,
  );

  @PATCH(ApiEndpoints.postCommentById)
  Future<IdResponseDto> updateComment(
    @Path('id') String id,
    @Body() UpdateCommentDto dto,
  );

  @DELETE(ApiEndpoints.postCommentById)
  Future<IdResponseDto> deleteComment(
    @Path('id') String id,
  );
}