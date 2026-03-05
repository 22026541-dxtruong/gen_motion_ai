import 'package:json_annotation/json_annotation.dart';

part 'auth_response.dto.g.dart'; // Tên file sinh ra phải khớp với tên file hiện tại

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'user_id')
  final String userId;
  final String email;
  final String username;
  @JsonKey(name: 'access_token')
  final String accessToken;

  AuthResponse({
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.username,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
