// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_up_credit.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopUpCreditDto _$TopUpCreditDtoFromJson(Map<String, dynamic> json) =>
    TopUpCreditDto(
      amount: (json['amount'] as num).toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$TopUpCreditDtoToJson(TopUpCreditDto instance) =>
    <String, dynamic>{'amount': instance.amount, 'note': ?instance.note};

TopUpCreditResponseDto _$TopUpCreditResponseDtoFromJson(
  Map<String, dynamic> json,
) => TopUpCreditResponseDto(
  userId: json['userId'] as String,
  amount: (json['amount'] as num).toInt(),
  balance: (json['balance'] as num).toInt(),
  reason: json['reason'] as String,
  transactionId: json['transactionId'] as String,
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TopUpCreditResponseDtoToJson(
  TopUpCreditResponseDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'amount': instance.amount,
  'balance': instance.balance,
  'reason': instance.reason,
  'transactionId': instance.transactionId,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
};
