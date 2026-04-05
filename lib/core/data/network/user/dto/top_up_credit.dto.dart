import 'package:json_annotation/json_annotation.dart';

part 'top_up_credit.dto.g.dart';

@JsonSerializable(includeIfNull: false)
class TopUpCreditDto {
  final int amount;
  final String? note;

  const TopUpCreditDto({required this.amount, this.note});

  factory TopUpCreditDto.fromJson(Map<String, dynamic> json) =>
      _$TopUpCreditDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TopUpCreditDtoToJson(this);
}

@JsonSerializable()
class TopUpCreditResponseDto {
  final String userId;
  final int amount;
  final int balance;
  final String reason;
  final String transactionId;
  final String? note;
  final DateTime createdAt;

  const TopUpCreditResponseDto({
    required this.userId,
    required this.amount,
    required this.balance,
    required this.reason,
    required this.transactionId,
    this.note,
    required this.createdAt,
  });

  factory TopUpCreditResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TopUpCreditResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TopUpCreditResponseDtoToJson(this);
}
