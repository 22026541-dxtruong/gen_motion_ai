import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/user/dto/user.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio) = _UserApi;

  @PATCH(ApiEndpoints.userMe)
  Future<UserDto> updateUser(@Body() UserDto body);

  @GET(ApiEndpoints.userMe)
  Future<UserDto> getMe();

  @DELETE(ApiEndpoints.userMe)
  Future<void> deleteUser();

  @GET(ApiEndpoints.userById)
  Future<UserDto> getUserById(@Path('userId') String userId);

}
