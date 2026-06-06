import 'package:freezed_annotation/freezed_annotation.dart';

part 'usage_entity.freezed.dart';
part 'usage_entity.g.dart';

/// Current report usage for the signed-in or anonymous user.
@freezed
abstract class UsageStatus with _$UsageStatus {
  const factory UsageStatus({
    @JsonKey(name: 'reports_used') required int reportsUsed,
    @JsonKey(name: 'reports_limit') required int reportsLimit,
    required String tier,
    @JsonKey(name: 'reset_at') required DateTime resetAt,
    @JsonKey(name: 'limit_reached') required bool limitReached,
  }) = _UsageStatus;

  factory UsageStatus.fromJson(Map<String, dynamic> json) =>
      _$UsageStatusFromJson(json);
}
