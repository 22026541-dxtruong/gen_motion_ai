import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/post/dto/create_post.dto.dart';
import 'package:gen_motion_ai/core/data/network/post/dto/get_post.dto.dart';
import 'package:gen_motion_ai/core/data/network/post/dto/post.dto.dart';
import 'package:gen_motion_ai/core/data/network/post/dto/update_post.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'post_api.g.dart';

@RestApi()
abstract class PostApi {
  factory PostApi(Dio dio) = _PostApi;

  @POST(ApiEndpoints.posts)
  Future<PostDto> createPost(@Body() CreatePostDto body);

  @GET(ApiEndpoints.posts)
  Future<List<PostDto>> getPosts();

  @GET(ApiEndpoints.postById)
  Future<GetPostDto> getPost(@Path('id') String id);

  @PATCH(ApiEndpoints.postById)
  Future<PostDto> updatePost(
    @Path('id') String id,
    @Body() UpdatePostDto body,
  );

  @DELETE(ApiEndpoints.postById)
  Future<PostDto> deletePost(@Path('id') String id);
}
