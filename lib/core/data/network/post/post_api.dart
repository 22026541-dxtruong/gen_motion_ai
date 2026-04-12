import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/dto/id_response.dto.dart';
import 'package:gen_motion_ai/core/data/network/post/dto/create_post.dto.dart';
import 'package:gen_motion_ai/core/data/network/post/dto/get_post.dto.dart';
import 'package:gen_motion_ai/core/data/network/post/dto/update_post.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'post_api.g.dart';

@RestApi()
abstract class PostApi {
  factory PostApi(Dio dio) = _PostApi;

  @POST(ApiEndpoints.posts)
  Future<IdResponseDto> createPost(@Body() CreatePostDto body);

  @GET(ApiEndpoints.posts)
  Future<List<GetPostDto>> getPosts();

  @GET('/posts/{id}')
  Future<GetPostDto> getPost(@Path('id') String id);

  @PUT('/posts/{id}')
  Future<IdResponseDto> updatePost(@Path('id') String id, @Body() UpdatePostDto body);

  @DELETE('/posts/{id}')
  Future<IdResponseDto> deletePost(@Path('id') String id);

}