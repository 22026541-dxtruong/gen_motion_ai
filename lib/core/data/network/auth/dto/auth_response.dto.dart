import 'package:json_annotation/json_annotation.dart';

part 'auth_response.dto.g.dart'; // Tên file sinh ra phải khớp với tên file hiện tại

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  AuthResponse({
    required this.accessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
