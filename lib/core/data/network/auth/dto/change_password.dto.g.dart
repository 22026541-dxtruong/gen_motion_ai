// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordDto _$ChangePasswordDtoFromJson(Map<String, dynamic> json) =>
    ChangePasswordDto(
      oldPassword: json['oldPassword'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$ChangePasswordDtoToJson(ChangePasswordDto instance) =>
    <String, dynamic>{
      'oldPassword': instance.oldPassword,
      'newPassword': instance.newPassword,
    };
