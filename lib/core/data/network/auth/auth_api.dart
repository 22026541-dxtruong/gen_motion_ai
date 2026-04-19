import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/change_password.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/auth_response.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/forgot_password.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/login.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/logout.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/refresh_token.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/register.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/reset_password.dto.dart';
import 'package:gen_motion_ai/core/data/network/dto/message_response.dto.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio) = _AuthApi;

  @POST(ApiEndpoints.register)
  Future<AuthResponse> register(@Body() RegisterDto body);

  @POST(ApiEndpoints.login)
  Future<AuthResponse> login(@Body() LoginDto body);

  @POST(ApiEndpoints.refresh)
  Future<AuthResponse> refresh(@Body() RefreshTokenDto body);

  @POST(ApiEndpoints.logout)
  Future<MessageResponseDto> logout(@Body() LogoutDto body);

  @POST(ApiEndpoints.logoutAll)
  Future<MessageResponseDto> logoutAll();

  @PATCH(ApiEndpoints.changePassword)
  Future<MessageResponseDto> changePassword(@Body() ChangePasswordDto body);

  @POST(ApiEndpoints.forgotPassword)
  Future<MessageResponseDto> forgotPassword(@Body() ForgotPasswordDto body);

  @POST(ApiEndpoints.resetPassword)
  Future<MessageResponseDto> resetPassword(@Body() ResetPasswordDto body);
}
