import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/auth_response.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/login.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/register.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio) = _AuthApi;

  @POST(ApiEndpoints.register)
  Future<AuthResponse> register(@Body() RegisterDto body);

  @POST(ApiEndpoints.login)
  Future<AuthResponse> login(@Body() LoginDto body);

}
